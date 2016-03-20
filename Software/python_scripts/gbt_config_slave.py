# By Kai Chen @ BNL, for FELIX GBT configuration and test

from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time

RegAddr=RegAddrTable()

phase=range(10)
phase=np.array(phase)
phaseB=range(10)
phaseB=np.array(phase)


ch=int(sys.argv[1])
timewait=0.05



if ch<12:
    ch=ch
else:
    ch=ch+4

# RX GTH RST
#reg_write32b(RegAddr.REG_GTHRXRST,2**ch)
#time.sleep(0.1)
#reg_write32b(RegAddr.REG_GTHRXRST,0)



# RX ALIGNMENT
reg_write1b(RegAddr.REG_TOPBOT,ch,0)
reg_write1b(RegAddr.REG_ODDEVEN,ch,0)

reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
#time.sleep(0.1)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
time.sleep(timewait)
ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
phase_cnt=10
oddeven=0
while phase_cnt != 0:
  #  print "phase_cnt is "+str(phase_cnt) 
  #  print ret
    if ret==0:
        if phase_cnt>1:
	    phase_cnt = phase_cnt - 1
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
 #           time.sleep(0.1)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
            time.sleep(timewait)
	    ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
        elif oddeven==0:
            reg_write1b(RegAddr.REG_ODDEVEN,ch,1)
         
            phase_cnt=10 
            oddeven=1
        #    print "oddeven is "+str(oddeven) 
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
           # time.sleep(0.1)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
            time.sleep(timewait)
	    ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
            
        else:
            phase_cnt=0
            top_find=0
    else:
	phase_cnt=0
        top_find=1

#print "top_find is "+str(top_find)  

if top_find==0:
    reg_write1b(RegAddr.REG_ODDEVEN,ch,0)
    reg_write1b(RegAddr.REG_TOPBOT,ch,1)
    phase_cnt=10
    oddeven=0
    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
   # time.sleep(0.1)
    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
    time.sleep(0.1)
    ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
    while phase_cnt !=0:
      #  print "phase_cnt is "+str(phase_cnt) 
     #   print ret
        if ret==0:
            if phase_cnt>1:
	        phase_cnt = phase_cnt - 1
                reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
                reg_write32b(RegAddr.REG_RXSLIDE,0)
                reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
                reg_write32b(RegAddr.REG_RXSLIDE,0)
	        reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
                #time.sleep(0.1)
	        reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
                time.sleep(timewait)
	        ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
            elif oddeven==0:
                reg_write1b(RegAddr.REG_ODDEVEN,ch,1)
                phase_cnt=10 
                oddeven=1
            #    print "oddeven is "+str(oddeven) 
                reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
                reg_write32b(RegAddr.REG_RXSLIDE,0)
                reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
                reg_write32b(RegAddr.REG_RXSLIDE,0)
	        reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
               # time.sleep(0.1)
	        reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
                time.sleep(timewait)
	        ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
            else:
                bot_find=0
                phase_cnt=0
        else:
	    phase_cnt=0
            bot_find=1
            topbot_final=1 # bot
else:
   # print "phase_cnt is "+str(phase_cnt) 
    master_ch=int(ch/4)*4
  #  print master_ch
    for i in range(10):
        phase[i]=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
        phaseB[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
      #  phase[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
        reg_write32b(RegAddr.REG_RXSLIDE,2**master_ch)
        reg_write32b(RegAddr.REG_RXSLIDE,0)
        reg_write32b(RegAddr.REG_RXSLIDE,2**master_ch)
        reg_write32b(RegAddr.REG_RXSLIDE,0)
        reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
               # time.sleep(0.1)
	reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
        time.sleep(timewait)
    print "PhaseA is: "
    print phase
    print "PhaseB is: " 
    print phaseB
    '''
    if phase[2]==1 and phase[1]==0:
        topbot_final=1
    elif phase[3]==1 and phase[2]==0:
        topbot_final=1
    elif phase[4]==1 and phase[3]==0:
        topbot_final=1
    elif phase[5]==1 and phase[4]==0:
        topbot_final=1
    elif phase[6]==1 and phase[5]==0:
        topbot_final=1
    else:
        topbot_final=0
    '''
    '''
    if np.sum(phase) == 10:
	print "Doing a 10x10 seconds scanning..."
    	for i in range(10):
    	    phase[i]=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
    	  #  phase[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
    	    reg_write32b(RegAddr.REG_RXSLIDE,2**master_ch)
    	    reg_write32b(RegAddr.REG_RXSLIDE,0)
    	    reg_write32b(RegAddr.REG_RXSLIDE,2**master_ch)
    	    reg_write32b(RegAddr.REG_RXSLIDE,0)
    	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
               # time.sleep(0.1)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
    	    time.sleep(10)
   	print phase   
    ''' 
    if np.sum(phase) < 10:
        find=0
        center=-1 
        for p in range(10):
            if find==0:
                if phase[p]==0:
                    left=phase[np.mod(p-1,10)]+phase[np.mod(p-2,10)]
                    right=phase[np.mod(p+1,10)]+phase[np.mod(p+2,10)]
                    if left==right:
                        find=1
                        center=p
                    elif right-left==1:
                        find=1
                        center=p  
    

        print "center is " + str(center)
        if center<8: 
            if center >2:
                topbot_final=0
            else:
                topbot_final=1
        else:
            topbot_final=1
    else:
        if phaseB[7]==1:
            if phaseB[6]==0:
                topbot_final=1
            else:
                topbot_final=0
        else:
            if phaseB[1]==0:
                topbot_final=0
            else:
                topbot_final=1


    if topbot_final==1:
        reg_read32b(RegAddr.REG_TOPBOT)
        reg_write1b(RegAddr.REG_TOPBOT,ch,1)
        reg_read32b(RegAddr.REG_TOPBOT)
        for i in range(5):
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)

#print "aaa"
reg_read32b(RegAddr.REG_TOPBOT)
#print "bbb"
reg_read32b(RegAddr.REG_ODDEVEN)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
#time.sleep(0.1)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
time.sleep(timewait)
ret=reg_read32b(RegAddr.REG_RX_ALIGNMENT_DONE)
print "RX_LOCK is "+str(ret)  
print "oddeven is "+str(oddeven)  
print "topbot is "+str(topbot_final)         

