# By Kai Chen @ BNL, for FELIX GBT configuration and test

import os
import numpy as np

def reg_read1b(addr,bit):
    addr_str=str(hex(addr))
   # print addr_str
    cmd="../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 32"
    retvalue = os.popen(cmd).readlines()
   # print retvalue
   # print retvalue[0][2:10]
    ret=int(str("{0:032b}".format((int(retvalue[0][2:10],16))))[31-bit])
  ##  print ret
    return ret

def reg_read32b(addr):
    addr_str=str(hex(addr))
    cmd="../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 32"
    retvalue = os.popen(cmd).readlines()
   # print retvalue[0][2:10]
##    ret="{0:032b}".format((int(retvalue[0][2:10],16)))
    ret="{0:08x}".format(int(retvalue[0][2:10],16))
  #  print ret
    return ret

def reg_read64b(addr):
    addr_str=str(hex(addr))
    cmd="../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 64"
    retvalue = os.popen(cmd).readlines()
   # print retvalue[0][2:10]
##    ret="{0:032b}".format((int(retvalue[0][2:10],16)))
    ret="{0:016x}".format(int(retvalue[0][2:18],16))
  #  print ret
    return ret

def reg_write32b(addr,data):
    addr_str=str(hex(addr))
    data_str=str(hex(data))
   # print data_str
    os.system("../f/pepo/pepo -u 1 -k -o " + addr_str + " -w "+ data_str + " -n 32")
def reg_write64b(addr,data):
    addr_str=str(hex(addr))
    data_str=str(hex(data))
   # print data_str
    os.system("../f/pepo/pepo -u 1 -k -o " + addr_str + " -w "+ data_str + " -n 64")

def reg_write1b(addr,bit_addr,bit_value):
    addr_str=str(hex(addr))
   # print addr_str
    cmd="../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 32"
    retvalue = os.popen(cmd).readlines()
  #  print 'a'
  #  print retvalue[0][2:10]
    ret=int(retvalue[0][2:10],16)
  #  print 'b'
  #  print ret

  #  print str(int(ret/2**(bit_addr+1))*2**(bit_addr))
  #  print bit_value
  #  print np.mod(ret,2**(bit_addr+1))
    newvalue=str(hex(int(ret/2**(bit_addr+1))*2**(bit_addr+1)+bit_value*2**(bit_addr)+np.mod(ret,2**(bit_addr))))
  #  print 'c'
  #  print newvalue
    os.system("../f/pepo/pepo -u 1 -k -o " + addr_str + " -w "+ newvalue + " -n 32")
  #  print 'dd'

#def regs_addr_init():
class RegAddrTable(object):
    REG_RXSLIDE             = 0x2480
    REG_TXUSRRDY            = 0x2490
    REG_RXUSRRDY            = 0x2494
    REG_SOFTRST_GTHTXRST    = 0x24A0
    REG_GTHRXRST            = 0x24A4
    REG_SOFTTXRST           = 0x24B4
    REG_SOFTRXRST           = 0x24C4
    REG_ODDEVEN             = 0x24D0
    REG_TOPBOT              = 0x24D4
    REG_RX_ALIGN_CHK_RST    = 0x2410
    REG_MOD_SEL             = 0x2420

    REG_TXRST_DONE          = 0x2680
    REG_RXRST_DONE          = 0x2684
    REG_TXFSMRST_DONE       = 0x2690
    REG_RXFSMRST_DONE       = 0x2694
    REG_CPLLFBCLK_LOST      = 0x26A0
    REG_CPLL_LOCK           = 0x26A4
    REG_RXCDRLOCK_QPLL_LOCK = 0x26B0
    REG_CLK_SAMPLED         = 0x26C0
    REG_GBT_VERSION         = 0x2600
    REG_GBTTXRST            = 0x2560
    REG_GBTRXRST            = 0x2564
    REG_OUT_SEL             = 0x2574
    REG_TXTC_SEL            = 0x2570
    REG_RX_FRAME_LOCK       = 0x2714
    REG_RX_ALIGNMENT_DONE   = 0x2720
    REG_OUTSEL_CALC         = 0x2724
    REG_RX_DECODER_ERR      = 0x2730
    REG_SPI_I2C_TRIG_ERRCHK = 0x208
    REG_CDCE_LOCK           = 0x310
    REG_ERR1                = 0x27C0
    REG_ERR2                = 0x27D0
    REG_ERR3                = 0x27E0
    REG_ERR4                = 0x27F0
    REG_TX_CXP1_FORMAT      = 0x2540
    REG_TX_CXP2_FORMAT      = 0x2544
    REG_RX_CXP1_FORMAT      = 0x2550
    REG_RX_CXP2_FORMAT      = 0x2554
    REG_TXOPT_LOW      = 0x2500
    #REG_TXOPT_LOW_HIGH     = 0x2504
    REG_TXOPT_HIGH      = 0x2510
    #REG_TXOPT_HIGH_HIGH     = 0x2514
    REG_RXOPT_LOW      = 0x2520
    #REG_RXOPT_LOW_HIGH     = 0x2524
    REG_RXOPT_HIGH      = 0x2530
    #REG_RXOPT_HIGH_HIGH     = 0x2534

    REG_TX_SEL              = 0x0220
    REG_RX_SEL              = 0x0210
   # REG_SMA_SEL
