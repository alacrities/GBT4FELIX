from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time

RegAddr=RegAddrTable()

phase=range(10)
phase=np.array(phase)

phaseb=range(10)
phaseb=np.array(phaseb)


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
        phaseb[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
      #  phase[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
        reg_write32b(RegAddr.REG_RXSLIDE,2**master_ch)
        reg_write32b(RegAddr.REG_RXSLIDE,0)
        reg_write32b(RegAddr.REG_RXSLIDE,2**master_ch)
        reg_write32b(RegAddr.REG_RXSLIDE,0)
        reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
               # time.sleep(0.1)
	reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
        time.sleep(timewait)

    print phaseb
    		    
    if phaseb[2]==0:
        if phaseb[1]==1:
            topbot_final=0
        else:
            topbot_final=1
    else:
        if phaseb[6]==1:
            topbot_final=1
        else:
            topbot_final=0
    
             

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

