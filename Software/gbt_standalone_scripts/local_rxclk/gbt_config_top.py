import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b, reg_write64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time

RegAddr=RegAddrTable()

print "configure I2C chips..."
reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,8)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,0)
time.sleep(2)


reg_write32b(RegAddr.REG_TXUSRRDY,0xFFF0FFF)
#reg_write32b(RegAddr.REG_TXUSRRDY,0)
reg_write32b(RegAddr.REG_RXUSRRDY,0xFFF0FFF)
#reg_write32b(RegAddr.REG_RXUSRRDY,0)
print "Quad Softreset..."
# Quad SoftRst
reg_write32b(RegAddr.REG_SOFTRST_GTHTXRST,0x70007000)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SOFTRST_GTHTXRST,0)
time.sleep(2)

print "Quad SoftTxreset..."
# Quad SoftTxRst
reg_write32b(RegAddr.REG_SOFTTXRST,0x70007000)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SOFTTXRST,0)
time.sleep(2)
reg_write32b(RegAddr.REG_TXOPT_CXP1_LOW,0x000000)
reg_write32b(RegAddr.REG_TXOPT_CXP2_LOW,0x000000)

print "GBT TX reset..."
# Channel GBTTXRST
reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTTXRST,0)
time.sleep(1)



reg_write32b(RegAddr.REG_RXOPT_CXP1_LOW,0x000)
reg_write32b(RegAddr.REG_RXOPT_CXP2_LOW,0x000)


reg_write32b(RegAddr.REG_GTHRXRST,0xFFF0FFF)
time.sleep(0.1)
reg_write32b(RegAddr.REG_GTHRXRST,0x0000000)

reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x55555500555555)
reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x55555500555555)



for ch in range(24):
    print ch
    os.system("python gbt_config.py " + str(23-ch))

print "GBT RX reset..."
reg_write32b(RegAddr.REG_GBTRXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTRXRST,0)
time.sleep(1)

