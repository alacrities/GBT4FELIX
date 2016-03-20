# README
This repository is about the optimized **GBT-FPGA** core for **FELIX** project in **ATLAS** experiment.
## Introduction
### Q&A
1. Where is this IP core used? 
	This IP is part of FELIX firmware.
   
2. Special conditions of FELIX.
 	- The configuration (if needed) of this GBT core is done via PCIe registers, by software. User should consider how to do it in his project.
 	- The FELIX is used as Back-End, it distributes the LHC clock to all of the Front-End. To simplify the data transmission from FE to FELIX, the reference clock for these links is required to be synchronized with the LHC clock. 
 	  + So FELIX directly use a local 240M clock (synchronized with LHC clock) as RXUSRCLK.
 	  + When using this core in FE, configurations should be changed. The RXOUTCLK should be used as RXUSRCLK.
 	  + The IP core supports this change, but we don't gurantee its stability. The manual should be read carefully, to find how to change the setting.
    
3. What is the difference between GBT part of this IP and the CERN GBT-FPGA IP core 3.0.2.
  - Based on 3.0.2. The Scrambler/Descrambler is almost from CERN version. The FEC encoder/decoder is from CERN version.
  - The GTX IP is removed, to make the GBT independent with the transceiver.  - The dynamic change of the GBT mode between normal FEC mode and Wide-Bus mode is provided, without FPGA reprogramming.  - A new RxGearBox with Rx alignment function are designed to replace the RxGearBox and framealigner provided by CERN GBT-FPGA. The alignment operation can be automatically done by firmware or controlled by software.  - The scrambler and descrambler are changed from 40 MHz clock domain to 240 MHz domain. Enable signal are added to control the descrambler and scrambler.  - The new time domain crossing between 40 MHz and 240 MHz are added in scrambler and descrambler.
  
4. For Virtex 7, about the GTH IP: 	- The low-level GTH configuration file is modified to decrease the latency. For example, RXCOMMADETEN is disabled.	- The TxOutClk of the master channel or external 240 MHz clock can be used to drive the TxUsrClk.	- The RxOutClk of the master channel or external 240 MHz clock can be used to drive the RxUsrClk.	- The bitslip is needed to do with the GTH output data. When the bitslip is finished, a stable GBT frame header is locked. At this time the phase between RxOutClk and RXUSRCLK is uncertain. A multiplexer is added to the GBT RxGearBox, to solve the time domain crossing problem for the 20 bit data transferred from RxOutClk to RxUsrClk in the GTH hard core.	- The GTH IP based on both of CPLL and QPLL are provided. Since MGTRefclk on HTG-710 can't be from TTC clock. GRefClk is the default configuration. Quad is the unit for the GTH IP.
	
5. For GTH in UltraScale:
  - Buffer in GTH receiver is enabled. Rx latency is bigger, but design is easier, no training is needed anymore. FELIX doesn't care latency in receiver so much.
  - More modes is under testing.
  
6. About the training of this GBT core.
  - The Virtex version, when RXUSRCLK is from local 240M (synchronized with LHC), training can be done by software (python script, or tool based on C language), or firmware (automatically when Rx link is reset).
  - The Virtex version, when RXUSRCLK is from RXOUTCLK of the master channel ineach quad, training can be done by software (python script), firmware FSM is not designed, since it isn't default mode for FELIX. User can design the FSM according to the python script.
  - The UltraScaleversion: no training is needed. The RxGearBox in GBT decoding firmware is also modified.

  
### Architecture of this IP
- Firmware:
  + GBT core: encoding+decoding
  + GTH core: Virtex QPLL version; Virtex CPLL version; Kintex UltrScale version.
- Software:
  + The C language tools are not given
  + The python examples are given. But they are based on the FELIX, PCIe registers are needed.
- Backup
  + An old version with VIVADO VIO.
   
## AOB 
- This repository may be updated without any schedule or notification.
- We don't gurantee any support to the use of this core. Please read the documents carefully before deciding to use it.
- The risk of damage to your board, or delay to your project schedule, should be taken by yourself.


