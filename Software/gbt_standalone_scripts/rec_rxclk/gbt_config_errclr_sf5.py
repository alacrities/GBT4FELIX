import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time

RegAddr=RegAddrTable()
#5592405

#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,1)
#reg_write1b(RegAddr.REG_RXSLIDE,0x400000,0)



ch=1
a=reg_read1b(RegAddr.REG_TOPBOT,ch)
reg_write1b(RegAddr.REG_TOPBOT,ch,1-a)

reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)
reg_write32b(RegAddr.REG_RXSLIDE,2**ch)
reg_write32b(RegAddr.REG_RXSLIDE,0)

reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,1)
#time.sleep(0.1)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)
time.sleep(1)
ret=reg_read32b(RegAddr.REG_RX_ALIGNMENT_DONE)
print "RX_LOCK is "+str(ret) 

reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,2)
time.sleep(1)
reg_write32b(RegAddr.REG_RX_ALIGN_CHK_RST,0)


