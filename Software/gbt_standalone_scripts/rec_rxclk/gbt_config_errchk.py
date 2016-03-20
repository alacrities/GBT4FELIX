import os
from gbt_config_lib import reg_write1b, reg_read32b, reg_read1b, reg_write32b, reg_read64b
from gbt_config_lib import RegAddrTable
import numpy as np
import sys 
import time
import datetime

RegAddr=RegAddrTable()



a=1
while a==1: 
    ret=reg_read32b(RegAddr.REG_RX_ALIGNMENT_DONE)
    print "align reg is " + str(ret)
    ret=reg_read64b(RegAddr.REG_RX_DECODER_ERR) 
    print "decoder error flag is "+str(ret)
    ret=reg_read64b(RegAddr.REG_ERR1)   
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
    ret=int(ret/2**10)
    ERR5=np.mod(int(ret),2**10)
    print "CH13 ERR NUM is "+str(ERR5)
    ret=int(ret/2**10)
  #  ERR1=np.mod(int(ret),2**10)
    print "CH14 ERR NUM is "+str(ret)




    ret=reg_read64b(RegAddr.REG_ERR2)
    print "REG2 ERR NUM is "+str(ret) 
    ret=int(ret,16)
    ERR7=np.mod(int(ret),2**10)
    print "CH15 ERR NUM is "+str(ERR7)
    ret=int(ret/2**10)
    ERR8=np.mod(int(ret),2**10)
    print "CH16 ERR NUM is "+str(ERR8)
    ret=int(ret/2**10)
    ERR9=np.mod(int(ret),2**10)
    print "CH5 ERR NUM is "+str(ERR9)
    ret=int(ret/2**10)
    ERR10=np.mod(int(ret),2**10)
    print "CH6 ERR NUM is "+str(ERR10)
    ret=int(ret/2**10)
    ERR11=np.mod(int(ret),2**10)
    print "CH7 ERR NUM is "+str(ERR11)
    ret=int(ret/2**10)
  #  ERR1=np.mod(int(ret),2**10)
    print "CH8 ERR NUM is "+str(ret)

    ret=reg_read64b(RegAddr.REG_ERR3)
    print "REG3 ERR NUM is "+str(ret) 
    ret=int(ret,16)
    ERR13=np.mod(int(ret),2**10)
    print "CH17 ERR NUM is "+str(ERR13)
    ret=int(ret/2**10)
    ERR14=np.mod(int(ret),2**10)
    print "CH18 ERR NUM is "+str(ERR14)
    ret=int(ret/2**10)
    ERR15=np.mod(int(ret),2**10)
    print "CH19 ERR NUM is "+str(ERR15)
    ret=int(ret/2**10)
    ERR16=np.mod(int(ret),2**10)
    print "CH20 ERR NUM is "+str(ERR16)
    ret=int(ret/2**10)
    ERR17=np.mod(int(ret),2**10)
    print "CH9 ERR NUM is "+str(ERR17)
    ret=int(ret/2**10)
  #  ERR1=np.mod(int(ret),2**10)
    print "CH10 ERR NUM is "+str(ret)

    ret=reg_read64b(RegAddr.REG_ERR4)
    print "REG4 ERR NUM is "+str(ret) 
    ret=int(ret,16)
    ERR19=np.mod(int(ret),2**10)
    print "CH11 ERR NUM is "+str(ERR19)
    ret=int(ret/2**10)
    ERR20=np.mod(int(ret),2**10)
    print "CH12 ERR NUM is "+str(ERR20)
    ret=int(ret/2**10)
    ERR21=np.mod(int(ret),2**10)
    print "CH21 ERR NUM is "+str(ERR21)
    ret=int(ret/2**10)
    ERR22=np.mod(int(ret),2**10)
    print "CH22 ERR NUM is "+str(ERR22)
    ret=int(ret/2**10)
    ERR23=np.mod(int(ret),2**10)
    print "CH23 ERR NUM is "+str(ERR23)
    ret=int(ret/2**10)
  #  ERR1=np.mod(int(ret),2**10)
    print "CH24 ERR NUM is "+str(ret)
    
    print datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
    time.sleep(6)




