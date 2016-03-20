import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b, reg_write64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time

RegAddr=RegAddrTable()


reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,8)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,0)
time.sleep(2)


reg_write32b(RegAddr.REG_TXUSRRDY,0xFFF0FFF)
reg_write32b(RegAddr.REG_TXUSRRDY,0)
reg_write32b(RegAddr.REG_RXUSRRDY,0xFFF0FFF)
reg_write32b(RegAddr.REG_RXUSRRDY,0)

# Quad SoftRst
reg_write32b(RegAddr.REG_SOFTRST_GTHTXRST,0x70007000)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SOFTRST_GTHTXRST,0)
time.sleep(2)
# Quad SoftTxRst
reg_write32b(RegAddr.REG_SOFTTXRST,0x70007000)
time.sleep(0.5)
reg_write32b(RegAddr.REG_SOFTTXRST,0)
time.sleep(2)
reg_write32b(RegAddr.REG_TXOPT_CXP1_LOW,0x000000)
reg_write32b(RegAddr.REG_TXOPT_CXP2_LOW,0x000000)

# Channel GBTTXRST
reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTTXRST,0)
time.sleep(1)

#reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
#time.sleep(0.5)
#reg_write32b(RegAddr.REG_GBTTXRST,0)
#time.sleep(3)

#reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
#time.sleep(0.5)
#reg_write32b(RegAddr.REG_GBTTXRST,0)
#time.sleep(3)

reg_write32b(RegAddr.REG_RXOPT_CXP1_LOW,0x000)
reg_write32b(RegAddr.REG_RXOPT_CXP2_LOW,0x000)
reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x55555500555555)

reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x55555500555555)

# RX GTH RST
reg_write32b(RegAddr.REG_GTHRXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GTHRXRST,0)
time.sleep(2)

for ch in range(24):
    print ch
    if np.mod(ch,4)==0:
        os.system("python gbt_config_master.py " + str(ch))
    else:
        os.system("python gbt_config_slave_new.py " + str(ch))

print "GBT RX reset..."
reg_write32b(RegAddr.REG_GBTRXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTRXRST,0)
time.sleep(1)

'''

for ch in range(6):
    print ch*4
    
    os.system("python gbt_config_rfsel.py " + str(ch*4))
'''

'''
for i in range(24):
    if i>11:
        ch=i+4
    else:
        ch=i
    rf_value=rf_value+rf_sel[i]*2**ch
       

print rf_value
'''
reg_write32b(RegAddr.REG_RF_SEL,0x0FFF0FFF)



