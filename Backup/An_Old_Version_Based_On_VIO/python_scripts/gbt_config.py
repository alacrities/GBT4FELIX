# By Kai Chen @ BNL, for FELIX GBT configuration and test 

from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys
import time

RegAddr=RegAddrTable()

phase=range(10)
phase=np.array(phase)


ch=int(sys.argv[1])
timewait=0.1

topbot_final=-1

if ch<12:
    ch=ch
else:
    ch=ch+4



# set TOPBOT & ODDEVEN to 0
reg_write1b(RegAddr.REG_TOPBOT,ch,0)
reg_write1b(RegAddr.REG_ODDEVEN,ch,0)

# check alignment status
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
time.sleep(timewait)
ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
# ret=1 means alignment is finished

phase_cnt=10
oddeven=0

while phase_cnt != 0:
  #  for each topbot oddeven, there are 10 phases, totally 40 phases.
  #  print ret
    if ret==0:
        if phase_cnt>1:
	    phase_cnt = phase_cnt - 1
            # shift 1 phase
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            #  check again
            reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
            time.sleep(timewait)
	    ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
	    #  print ret
        elif oddeven==0:
            # When topbot=0, oddeven=0 has no good phase,
            # then change oddeven to 1
            reg_write1b(RegAddr.REG_ODDEVEN,ch,1)

            phase_cnt=10
            oddeven=1
            # print "oddeven is "+str(oddeven)
            # shift 1 phase and check again
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
	    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
            time.sleep(timewait)

	    ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
            #  print ret
        else:
            # topbot=0, has no good phase
            phase_cnt=0
            top_find=0
    else:
        # One good phase is found
	phase_cnt=0
        top_find=1

#print "top_find is "+str(top_find)

if top_find==0:
    # If topbot=0 has no good phase, change topbot=1, oddeven=0
    # redo similar operation with topbot=0
    reg_write1b(RegAddr.REG_ODDEVEN,ch,0)
    reg_write1b(RegAddr.REG_TOPBOT,ch,1)

    phase_cnt=10
    oddeven=0
    # check alignment status
    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
    reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
    time.sleep(0.1)
    ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)

    while phase_cnt !=0:
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
		reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
                time.sleep(timewait)
	        ret=reg_read1b(RegAddr.REG_RX_ALIGNMENT_DONE,ch)
            else:
                bot_find=0
                phase_cnt=0
        else:
            # a good phase is found
	    phase_cnt=0
            bot_find=1
            topbot_final=1 # topbot=1 is recommended
else:
    # When topbot=0 has a good phase, do below operation to obtain topbot value
    # print "phase_cnt is "+str(phase_cnt)
    for i in range(10):
        # Shift the RXOUTCLK, and use RXUSRCLK to sample the 10 phases.
        # TO obtain the phase between them
        phase[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
        reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
        reg_write32b(RegAddr.REG_RXSLIDE,0)
        reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
        reg_write32b(RegAddr.REG_RXSLIDE,0)
    # Calculate the recommended topbot value, according to the phase between them.
    if phase[1]==1:
        if phase[0]==0:
            topbot_final=1
        else:
            topbot_final=0
    else:
        if phase[5]==0:
            topbot_final=0
        else:
            topbot_final=1
    print phase
    if topbot_final==1:
        # If recommended value is 1, then shift phase by 5
        reg_read32b(RegAddr.REG_TOPBOT)
        reg_write1b(RegAddr.REG_TOPBOT,ch,1)
        reg_read32b(RegAddr.REG_TOPBOT)
        for i in range(5):
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
            reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
            reg_write32b(RegAddr.REG_RXSLIDE,0)
#print "aaa"

# Print the final 10 phases sampled results
for i in range(10):
    phase[i]=reg_read1b(RegAddr.REG_CLK_SAMPLED,ch)
    reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
    reg_write32b(RegAddr.REG_RXSLIDE,0)
    reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
    reg_write32b(RegAddr.REG_RXSLIDE,0)
print phase

#reg_read32b(RegAddr.REG_TOPBOT)
#reg_read32b(RegAddr.REG_ODDEVEN)

# check alignment
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
time.sleep(timewait)
ret=reg_read32b(RegAddr.REG_RX_ALIGNMENT_DONE)

print "Rx header locking status is "+str(ret)
print "oddeven is "+str(oddeven)
print "topbot is "+str(topbot_final)
