import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b, reg_write64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys
import time


## For firmware testing, please use 'python gbt_config_top_rx.py 8 0 0', or 'python gbt_config_top_rx.py 16 0 0'
## the second and third parameters are only needed if the latency is not fixed.

## Channel numbers, will be used when RX_ALIGN_MODE = 1
TOTAL_CH_NUM=int(sys.argv[1])

## Rx alignmode: 0, use FSM in firmware; 1, use Software
RX_ALIGN_MODE=int(sys.argv[2])

## TOPBOT value sources:
## 0: use the value calculated by FSM of Software
## 1: use the value from database if it works
TOPBOT_MODE=int(sys.argv[3])

## The value from database
## anytime when cable length or board, or firmware is changed, let TOPBOT_MODE=0 to run one time
## If use software to Rx align, after the alignment, save 0x2510 to the database for this board
## If use FSM to Rx align, after the alignment, read 0x2760, save it to the database.
TOPBOT_DATA_BASE=0x00060F42


DESMUX_MODE=0


RegAddr=RegAddrTable()

timewait=0.1

print "GBT RX Latency Optimization for all channels..."
reg_write64b(RegAddr.REG_RXOPT_LOW,0x000000)

print "GTH RX reset for all channels..."
reg_write32b(RegAddr.REG_GTHRXRST,0xFFF0FFF)
time.sleep(0.1)
reg_write32b(RegAddr.REG_GTHRXRST,0x0000000)

print "Set the RX GBT encoding mode for all channels..."

reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x0000000000000000)



if RX_ALIGN_MODE==0:
    if TOPBOT_MODE==0:
        reg_write32b(RegAddr.REG_MODESEL,(0x0+DESMUX_MODE))
        time.sleep(1)    

    else:
        reg_write32b(RegAddr.REG_TOPBOT,TOPBOT_DATA_BASE)
        reg_write32b(RegAddr.REG_MODESEL,(0x4+DESMUX_MODE))
        time.sleep(1)

else:  
    reg_write32b(RegAddr.REG_MODESEL,(0x2+DESMUX_MODE))
    print "GBT RX alignment channel by channel..."
    for ch in range(TOTAL_CH_NUM):
        print ch
        os.system("python gbt_config.py " + str(ch) +" " + str(TOPBOT_MODE) + " " + str('{0:016b}'.format(TOPBOT_DATA_BASE)[ch]))



print "GBT RX reset for all channels..."
reg_write32b(RegAddr.REG_GBTRXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTRXRST,0)
time.sleep(1)

print "Calculate the recommended selection for descrambler output multiplexer..."

OUTSEL=reg_read32b(RegAddr.REG_OUTSEL_CALC)

print "Calculated value for all channels " + OUTSEL

reg_write32b(RegAddr.REG_OUT_SEL,int(OUTSEL,16))

print "Recheck the RX alignment..."
time.sleep(0.5)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
time.sleep(0.5)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)

time.sleep(timewait)
ret=reg_read32b(RegAddr.REG_RX_ALIGNMENT_DONE)



print "Rx header locking status is "+str(ret)

ret=reg_read32b(RegAddr.REG_RX_DECODER_ERR)

print "FEC decoder error status is "+str(ret)
