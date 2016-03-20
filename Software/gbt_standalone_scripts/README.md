Updated at 20150327

- For HTG710
 
- For these four configurations, the GTH reference clock is from the on-board oscillator, channels of CXP1 and CXP2 use different clock sources.
 
- The local\_rxclk and rec\_rxclk:
  + The local\_rxclk use local 240M to drive the RXUSRCLK.
  + The rec\_rxclk: for each quad, RXOUTCLK of the master channel is used to drive RXUSRCLK of all the 4 channels in the quad.
  + When using these two configurations, the TX and RX should be same reference clock, that means the CXP1 channels must be connected to CXP1, the CXP2 channels must be connected to CXP2. There is no requirement for the channel-to channel mapping.
   
- The local\_rxclk\_cxp1-cxp2 and rec\_rxclk\_cxp1-cxp2:
  + The local\_rxclk use local 240M to drive the RXUSRCLK.
  + The rec\_rxclk: for each quad, RXOUTCLK of the master channel is used to drive RXUSRCLK of all the 4 channels in the quad. 
  + When using these two configurations, the CXP1 channels must be connected to CXP2, the CXP2 channels must be connected to CXP1. There is no requirement for the channel-to channel mapping. 
  
- Please use the local\_rxclk\_cxp1-cxp2. The rec\_rxclk\_cxp1-cxp2 and rec\_rxclk will not be updated, because they will not be used in future FELIX development. The local\_rxclk is just a special case of local\_rxclk\_cxp1-cxp2. 

- Steps after the PCIe driver is loaded:
  + python gbt\_config\_top.py
    * to configure the 24 GBT links 
  + gbt\_configure\_errclk.py, error counter reset, and choose GBT mode
    * python gbt\_config\_errclr.py 1 (to choose WideBus mode)
    * python gbt\_config\_errclr.py 0 (to choose Normal mode)    
  + python gbt\_config\_errchk.py 
    * start the error checking, check the counters per 6 seconds
    
- Others:	    
  + The pepo is used now
  + The GBT encoding/decoding include the scrambler and descrambler, so the PRBS is not used in the data generator and data checker
  + For the GBT links, the data source: each bit changes like 0 -> 1 -> 0 -> 1, in the clock domain of 40MHz TX FrameClk.
  + In the RX FrameClk domain, we check whether the bit(111-72) = bit(71-32), and bit(31-16) = bit(15-0)