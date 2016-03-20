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
    REG_RXSLIDE             = 0x5480
    REG_TXUSRRDY            = 0x5490
    REG_RXUSRRDY            = 0x54A0
    REG_SOFTRST_GTHTXRST    = 0x54B0
    REG_GTHRXRST            = 0x54C0
    REG_SOFTTXRST           = 0x54E0
    REG_SOFTRXRST           = 0x54F0
    REG_ODDEVEN             = 0x5500
    REG_TOPBOT              = 0x5510
    REG_RX_ALIGN_CHK_RST    = 0x5410
    REG_MODESEL             = 0x5420

    REG_TXRST_DONE          = 0x6680
    REG_RXRST_DONE          = 0x6690
    REG_TXFSMRST_DONE       = 0x66A0
    REG_RXFSMRST_DONE       = 0x66B0
    REG_CPLLFBCLK_LOST      = 0x66C0
    REG_CPLL_LOCK           = 0x66D0
    REG_RXCDRLOCK_QPLL_LOCK = 0x66E0
    REG_CLK_SAMPLED         = 0x66F0
    REG_GBT_VERSION         = 0x6600

    REG_TXPHASE_A           = 0x5520
    REG_TXPHASE_B           = 0x5530

    REG_GBTTXRST            = 0x5580
    REG_GBTRXRST            = 0x5590
    REG_OUT_SEL             = 0x55B0
    REG_TXTC_SEL            = 0x55A0

    REG_RX_FRAME_LOCK       = 0x6720
    REG_RX_ALIGNMENT_DONE   = 0x6730
    REG_OUTSEL_CALC         = 0x6740
    REG_RX_DECODER_ERR      = 0x6750
    REG_TOPBOT_FROM_FSM     = 0x6760
    REG_CLOCK_VEC_A         = 0x6770
    REG_CLOCK_VEC_B         = 0x6780
    REG_CLOCK_VEC_C         = 0x6790
    REG_CLOCK_VEC_D         = 0x67A0

    REG_SPI_I2C_TRIG_ERRCHK = 0x208
    REG_CDCE_LOCK           = 0x310
    REG_ERR1                = 0x67C0
    REG_ERR2                = 0x67D0
    REG_ERR3                = 0x67E0
    REG_ERR4                = 0x67F0
    REG_TX_CXP1_FORMAT      = 0x5560
    REG_RX_CXP1_FORMAT      = 0x5570
    REG_TXOPT_LOW      = 0x5540
    #REG_TXOPT_LOW_HIGH     = 0x5504
    #REG_TXOPT_HIGH      = 0x5510
    #REG_TXOPT_HIGH_HIGH     = 0x5514
    REG_RXOPT_LOW      = 0x5550
    #REG_RXOPT_LOW_HIGH     = 0x5524
    #REG_RXOPT_HIGH      = 0x5530
    #REG_RXOPT_HIGH_HIGH     = 0x5534

    REG_TX_SEL              = 0x0220
    REG_RX_SEL              = 0x0210
   # REG_SMA_SEL
