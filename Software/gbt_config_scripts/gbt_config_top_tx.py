import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b, reg_write64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys
import time

RegAddr=RegAddrTable()

#print "configure I2C chips..."
#reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,8)
#time.sleep(0.5)
#reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,0)
#time.sleep(2)

#Choose TX and RX sources
#reg_write32b(RegAddr.REG_TX_SEL,0x0)
#reg_write32b(RegAddr.REG_RX_SEL,0x0)

print "Set TXUSRRDY & RXUSRRDY..."
reg_write32b(RegAddr.REG_TXUSRRDY,0xFFF0FFF)
#reg_write32b(RegAddr.REG_TXUSRRDY,0)
reg_write32b(RegAddr.REG_RXUSRRDY,0xFFF0FFF)
#reg_write32b(RegAddr.REG_RXUSRRDY,0)

print "Quad Softreset for all quads..."
reg_write32b(RegAddr.REG_SOFTRST_GTHTXRST,0x70007000)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SOFTRST_GTHTXRST,0)
time.sleep(2)

print "Quad SoftTxreset for all quads..."
reg_write32b(RegAddr.REG_SOFTTXRST,0x70007000)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SOFTTXRST,0)
time.sleep(2)

print "Set the TX GBT encoding mode for all channels..."
reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x0000000000000000)





print "GBT TX Latency Optimization for all channels... "
reg_write64b(RegAddr.REG_TXOPT_LOW,0x000000000000)


print "Set TX Timedomain Crossing method..."
## 1: can gurantee a fixed latency, but need more test to verify it
#reg_write32b(RegAddr.REG_TXTC_SEL,0x0FFF0FFF)

## 0:
reg_write32b(RegAddr.REG_TXTC_SEL,0x00000000)


print "GBT TX Reset for all channels..."
reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTTXRST,0)
time.sleep(1)
