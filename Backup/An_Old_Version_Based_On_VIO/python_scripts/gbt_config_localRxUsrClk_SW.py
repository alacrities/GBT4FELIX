# By Kai Chen @ BNL, for FELIX GBT configuration and test

import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b, reg_write64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys
import time
import datetime

RegAddr=RegAddrTable()
timewait=0.1
#print "configure I2C chips..."
#reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,8)
#time.sleep(0.5)
#reg_write32b(RegAddr.REG_SPI_I2C_TRIG_ERRCHK,0)
#time.sleep(2)

#Choose TX and RX sources
#reg_write32b(RegAddr.REG_TX_SEL,0x0)
#reg_write32b(RegAddr.REG_RX_SEL,0x0)

print "Set Rx Alignment Mode to Software control"
reg_write32b(RegAddr.REG_MOD_SEL,0x2)

print "Set TXUSRRDY & RXUSRRDY..."
reg_write32b(RegAddr.REG_TXUSRRDY,0xFFF0FFF)
#reg_write32b(RegAddr.REG_TXUSRRDY,0)
reg_write32b(RegAddr.REG_RXUSRRDY,0xFFF0FFF)
#reg_write32b(RegAddr.REG_RXUSRRDY,0)

print "Set TX Timedomain Crossing method..."
reg_write32b(RegAddr.REG_TXTC_SEL,0x00000000)

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

print "GBT TX Latency Optimization for all channels... "
reg_write64b(RegAddr.REG_TXOPT_LOW,0xFFFFFFFFFFFF)

print "GBT TX Reset for all channels..."
reg_write32b(RegAddr.REG_GBTTXRST,0xFFF0FFF)
time.sleep(0.5)
reg_write32b(RegAddr.REG_GBTTXRST,0)
time.sleep(1)

#### RX

print "GBT RX Latency Optimization for all channels..."
reg_write64b(RegAddr.REG_RXOPT_LOW,0x000000)

print "GTH RX reset for all channels..."
reg_write32b(RegAddr.REG_GTHRXRST,0xFFF0FFF)
time.sleep(0.1)
reg_write32b(RegAddr.REG_GTHRXRST,0x0000000)



mod=int(sys.argv[1])

if mod==0:
    print "aaa"
    reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x0000000000000000)

    reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x0000000000000000)
    print "Set the TX & RX GBT encoding mode to be FEC for all channels..."

elif mod==1:
    reg_write64b(RegAddr.REG_TX_CXP1_FORMAT,0x0055555500555555)

    reg_write64b(RegAddr.REG_RX_CXP1_FORMAT,0x0055555500555555)

    print "Set the TX & RX GBT encoding mode  to be wide-bus for all channels..."


print "GBT RX alignment channel by channel..."
for ch in range(4):
    print ch
    os.system("python gbt_config.py " + str(ch))


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



a=1
while a==1: 
    ret=reg_read32b(RegAddr.REG_RX_ALIGNMENT_DONE)
    print "align reg is " + str(ret)
    ret=reg_read32b(RegAddr.REG_RX_DECODER_ERR) 
    print "for FEC only: decoder error flag is "+str(ret) 
    ret=reg_read64b(RegAddr.REG_ERR4)   
    print "REG1 ERR NUM is "+str(ret) 
    ret=int(ret,16)
    ERR1=np.mod(int(ret),2**10)
    print "CH1 ERR NUM is "+str(ERR1)
    ret=int(ret/2**10)
    ERR2=np.mod(int(ret),2**10)
    print "CH2 ERR NUM is "+str(ERR2)
    ret=int(ret/2**10)
    ERR3=np.mod(int(ret),2**10)
    print "CH3 ERR NUM is "+str(ERR3)
    ret=int(ret/2**10)
    ERR4=np.mod(int(ret),2**10)
    print "CH4 ERR NUM is "+str(ERR4)
    

    print datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
    time.sleep(6)

print "Rx header locking status is "+str(ret)

print "Rx header locking status is "+str(ret)
