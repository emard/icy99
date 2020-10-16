# icy99
TI-99/4A FPGA implementation for the Icestorm toolchain.
Primary target board currently the ULX3S FPGA board. Tested with the version 3.0.3 of the board with the ECP5 85F FPGA chip.

2020-10-16 ULX3S Supports loading with ESP32
=============================================
* Updated ESP32 micropython code slightly (esp32/osd/osd.py and esp32/osd/ld_ti99_4a.py), mainly to support the 2M ROM cartridge region from 2M to 4M in physical address space.
* Changed src/sys.v to support the ESP32 bootloader. Now there is a new parameter for synthesis, enabling the use of external memory controller instead of serloader (i.e. initializing with UART connected to US1).
* Still work in progress. 
    * "Don't mess with Texas" demo still does not work properly. There is at least a bug in the 5th sprite per line detection, and the demo eventually gets stuck. Also the very first part of the demo looks bogus, this might be a bug in the Verilog version of my CPU core.
    * Thus if you try with this 512K demo cartridge, just be patient and wait for the first phase of the demo to end, it is just garbage perhaps for the first two minutes.
* I did not test this latest build with BlackIce-II board at all.
* Credits: ULX3S intial port by emard. DVI encoder, TMS9902 and SDRAM controller cores by pnr.
* My own code: toplevel modules, generic system module implementing the TI-99/4A, TMS9900 CPU core, TMS9901 I/O controller core, TMS9918 Video processor core, serloader, spi-slave, TI-99/4A GROM system and the multiport memory controller xmemctrl. And of course the EP994A VHDL SoC this icy99 system is based on.

2020-10-15 SDRAM support and 80 column output
=============================================
* Did a whole bunch of updates and bug fixes to the VDP. Now the 40 column text mode should be bug free, and also added 80-column text mode, which is the same as with F18A, 9938 and 9958 VDPs. Tested with the TI-99/4A TurboForth.
* On the ULX3S added support for SDRAM.  This is still minimally used, the but now the 32K memory expansion and the scratchpad memory are stored in SDRAM instead of internal block RAM.
* Extended the address buses to 24-bits. The next step is to add memory paging to be able to benefit from the larger memory capacity.

2020-07-14 A couple of changes
==============================
Tested these changes with ULX3S and Blackice-II boards.
* Keyboard input from PS/2 keyboard improved. Now the cursor keys work, fixed the "minus" key, and backspace is the same as cursor left. Much easier to use.
* New definition EXTERNAL_VRAM can be used to define whether VRAM is in external memory or not. For the Blackice-II target it must be defined, as there is not enough block RAM on-chip. But for larger FPGAs, this can be left undefined, and then FPGA's internal block RAM will be used for VRAM. This is useful as in the future SDRAM support will be added for the ULX3S and hopefully Flea Ohm board too. With VRAM accesses out of the way, the CPU can access leisurely SDRAM even with a slow SDRAM controller, that is the idea.
* Internal block RAMs are all operated with 25MHz clock if EXTERNAL_VRAM is defined. If it is not defined, the VRAM clocks on the toplevel module run off the 125MHz (DVI video PLL).

Initial commit 2020-06-15 
=========================
I will add documentation once I have a bit more time. The software stucture is a bit of a mess. I am moving the files into this github repository from my own repository, please let me know if some files are missing.

The system here is a verilog port from my existing EP994A VHDL version of the TI-99/4A. The main difference between this version is that a unified memory architecture (UMA) model is supported, allowing this core to run even on the Blackice-II board, with the modest ICE40HX4K FPGA. This FPGA does not have enough block RAM to support the video system memory on-chip. Thus, thanks to UMA, the external 256K x 16bit memory is used for both CPU RAM, ROM, GROM and VDP RAM memories.

The archictecture runs at 25MHz, the performance is around 7x of the original TI-99/4A. My initial goal with the EP994 was to build a very fast TI-99/4A implementation. Due to this the core has never been cycle accurate. I may accurate this later.

The repository does not include ROM files. The necessary ROM files are:
* 994AGROM.Bin system GROM file
* 994aROM.Bin system ROM 

create-mem-from-bin.py is a Python 3 program which will generate Verilog memory initialization files from binary files.

The design targets the following FPGA boards:
| Board       | top module      | make target |
|-------------|-----------------|-------------|
| ULX3S       | top_ulx3s.v     | ti994a_ulx3s.bit |
| Blackice-II | top_blackice2.v | next9900.bin |
| Flea Ohm    | top_flea.v      | flea_ohm.bit |

 Thus, for example to build the version for flea_ohm board:

 make flea_ohm.bit
 
 The ULX3S and Flea Ohm versions of this system embed the TI-99/4A ROMS as FGPA block RAMs. For the BlackIce-II board this is not possible, as the internal block RAM capacity is too small. For that system (and also the others) the ROMs can be initilized with the MEMLOADER program. This is a Windows program enabling the memories to be initialized over a serial port. I believe I have documented some of this in the EP994A. I will add the memloader source code to this repository later as well.
 
I have used a mixed computer setup for development: a windows box running Windows Subsystem for Linux as the main development environment to run Icestorm (yosys, nextpnr), a Mac for some of the development with the same toolchain. Windows is required currently to run MEMLOADER.
