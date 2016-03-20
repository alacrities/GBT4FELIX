import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b, reg_write64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys
import time

RegAddr=RegAddrTable()

timewait=0.1

print "Set the TX & RX GBT encoding mode for all channels..."
reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x0000000000000000)
reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x0000000000000000)

print "Set TX Timedomain Crossing method..."


## 1: can gurantee a fixed latency
#reg_write32b(RegAddr.REG_TXTC_SEL,0x0FFF0FFF)

## When using this option, the 0x2580 and 0x2590 need to be configured, to select a best phase from 0-5, make the data transferred from 40M to 240M is right, and has the lowest latency.

## 0:
reg_write32b(RegAddr.REG_TXTC_SEL,0x00000000)

print "GBT TX Latency Optimization for all channels... "
reg_write64b(RegAddr.REG_TXOPT_LOW,0xFFFFFFFFFFFF)

print "GBT TX Reset for all channels..."
reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTTXRST,0)
time.sleep(1)


print "GBT RX Latency Optimization for all channels..."
reg_write64b(RegAddr.REG_RXOPT_LOW,0xFFFFFF)


print "GBT RX reset for all channels..."
reg_write32b(RegAddr.REG_GBTRXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTRXRST,0)
time.sleep(1)

print "Calculate the recommended selection for descrambler output multiplexer..."

OUTSEL=reg_read32b(RegAddr.REG_OUTSEL_CALC)

print "Calculated value for all channels " + OUTSEL
#OUTSEL="0x00000f"
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
