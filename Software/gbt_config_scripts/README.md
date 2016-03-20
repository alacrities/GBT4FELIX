# Configuration of the GBT

Take TTC channel as example:


1. Program the FPGA, reboot the PC (or use hotplug), load the PCIe driver. Make sure the 40M clock and 240M clock are stable.

2. Write 0 to 0x220 and 0x210, to choose TTC as the GBT data source. Write 0x28 to 0x1100, to choose the L1A for the RX testpoint SMA output. (When using the GBTx test board, use 0x29.)

3. GBT Transmitter configuration: 
	`python gbt_config_top_tx.py`
	
4. When the front-end sending a stable GBT data, we can do the GBT Receiver configuration:
	`python gbt_config_top_rx.py`  
	
5. After 3 & 4, the link should be stable, we should be able to see the receivered L1A.

6. We can optionally use `python gbt_config_latopt.py` to set the GBT mode for each channel's Tx and Rx part, and configure the latency optimization register for Tx and Rx side. See the script and the register definition for the details, and change the register value as needed. 


- The scripts configure all the channels at the same time, to configure a single channel, see the register definition, and write & read the bit for this channel.
- When using RXOUTCLK as RXUSCLK, try gbt\_config\_master.py for master channels, and gbt\_config\_slave\_new.py for slave channels.