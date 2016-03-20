import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_write64b, reg_read64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time

RegAddr=RegAddrTable()
#5592405

mod=int(sys.argv[1])

if mod==1:
    print "aaa"
    reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x55555500555555)

    reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x55555500555555)

elif mod==2:
    reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x00000000555555)

    reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x00000000555555)


else:
    print "bbb"
    reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x00000000000000)
    reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x00000000000000)

reg_write32b(RegAddr.REG_TXOPT_CXP1_LOW,0xFFFFFF)
reg_write32b(RegAddr.REG_TXOPT_CXP2_LOW,0xFFFFFF)
reg_write32b(RegAddr.REG_RXOPT_CXP1_LOW,0x000000) 
reg_write32b(RegAddr.REG_RXOPT_CXP2_LOW,0x000000)
print "GBT TX reset..."
reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTTXRST,0)
time.sleep(1)
print "GBT RX reset..."
reg_write32b(RegAddr.REG_GBTRXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTRXRST,0)
time.sleep(1)

OUTSEL=reg_read32b(RegAddr.REG_OUTSEL_CALC)
print OUTSEL
reg_write32b(RegAddr.REG_OUT_SEL,int(OUTSEL,16))


time.sleep(0.5)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,3)
time.sleep(0.5)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)



