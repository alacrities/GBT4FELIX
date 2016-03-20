import os
import numpy as np

def reg_read1b(addr,bit):
    addr_str=str(hex(addr))
   # print addr_str
    cmd="../../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 32"
    retvalue = os.popen(cmd).readlines()
   # print retvalue
   # print retvalue[0][2:10]
    ret=int(str("{0:032b}".format((int(retvalue[0][2:10],16))))[31-bit])
  ##  print ret
    return ret

def reg_read32b(addr):
    addr_str=str(hex(addr))
    cmd="../../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 32"
    retvalue = os.popen(cmd).readlines()
   # print retvalue[0][2:10]
##    ret="{0:032b}".format((int(retvalue[0][2:10],16)))
    ret="{0:08x}".format(int(retvalue[0][2:10],16))
  #  print ret
    return ret

def reg_read64b(addr):
    addr_str=str(hex(addr))
    cmd="../../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 64"
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
    os.system("../../f/pepo/pepo -u 1 -k -o " + addr_str + " -w "+ data_str + " -n 32")
def reg_write64b(addr,data):
    addr_str=str(hex(addr))
    data_str=str(hex(data))
   # print data_str
    os.system("../../f/pepo/pepo -u 1 -k -o " + addr_str + " -w "+ data_str + " -n 64")

def reg_write1b(addr,bit_addr,bit_value):
    addr_str=str(hex(addr))
   # print addr_str
    cmd="../../f/pepo/pepo -u 1 -k -o " + addr_str + " -r -n 32"
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
    os.system("../../f/pepo/pepo -u 1 -k -o " + addr_str + " -w "+ newvalue + " -n 32")
  #  print 'dd'

#def regs_addr_init():
class RegAddrTable(object):
    REG_RXSLIDE= 0x480
    REG_TXUSRRDY= 0x490
    REG_RXUSRRDY= 0x494
    REG_SOFTRST_GTHTXRST= 0x4A0
    REG_GTHRXRST= 0x4A4
    REG_SOFTTXRST= 0x4B4
    REG_SOFTRXRST=0x4C4
    REG_ODDEVEN= 0x4D0
    REG_TOPBOT= 0x4D4
    REG_RX_ALIGN_CHK_RST= 0x410

    REG_TXRST_DONE= 0x680
    REG_RXRST_DONE= 0x684
    REG_TXFSMRST_DONE= 0x690
    REG_RXFSMRST_DONE= 0x694
    REG_CPLLFBCLK_LOST= 0x6A0
    REG_CPLL_LOCK= 0x6A4
    REG_RXCDRLOCK_QPLL_LOCK= 0x6B0
    REG_CLK_SAMPLED= 0x6C0
    REG_GBT_VERSION= 0x600
    REG_GBTTXRST= 0x560
    REG_GBTRXRST= 0x564
    REG_OUT_SEL= 0x574
    REG_RX_FRAME_LOCK= 0x714
    REG_RX_ALIGNMENT_DONE= 0x720
    REG_OUTSEL_CALC= 0x724
    REG_RX_DECODER_ERR= 0x730
    REG_SPI_I2C_TRIG_ERRCHK= 0x208
    REG_CDCE_LOCK= 0x310
    REG_ERR1 =0x7C0
    REG_ERR2 =0x7D0
    REG_ERR3 =0x7E0
    REG_ERR4 =0x7F0
    REG_TX_CXP1_FORMAT=0x540
    REG_TX_CXP2_FORMAT=0x544
    REG_RX_CXP1_FORMAT=0x550
    REG_RX_CXP2_FORMAT=0x554 
    REG_TXOPT_CXP1_LOW=0x500
    REG_TXOPT_CXP1_HIGH=0x504
    REG_TXOPT_CXP2_LOW=0x510
    REG_TXOPT_CXP2_HIGH=0x514
    REG_RXOPT_CXP1_LOW=0x520
    REG_RXOPT_CXP1_HIGH=0x524
    REG_RXOPT_CXP2_LOW=0x530
    REG_RXOPT_CXP2_HIGH=0x534

   
