# 2023-Spring IC Design Lab  

Instructor: 李鎮宜 Chen-Yi Lee  
[National Yang Ming Chiao Tung University](https://www.nycu.edu.tw/) (NYCU)  
Website: http://si2web.lab.nycu.edu.tw/course/  

## Overview

&nbsp;&nbsp;&nbsp;&nbsp;In IC-lab, we perform a top-down design flow listed below to design the VLSI chips, based on standard cell library as well as full-custom layout approaches.  
&nbsp;&nbsp;&nbsp;&nbsp;To run RTL and other simulations, we use *irun* from [Cadence](https://www.cadence.com/), and to sythesis RTL design to gate-level one, we use [Design Compiler](https://www.synopsys.com/implementation-and-signoff/rtl-synthesis-test/dc-ultra.html) from [Synopsys](https://www.synopsys.com/). To generate memory models, we use the software tool from Artisan Components Inc., and to run APR, we use [Innovus](https://www.cadence.com/en_US/home/tools/digital-design-and-signoff/soc-implementation-and-floorplanning/innovus-implementation-system.html) from Cadence again. Besides, we use [JasperGold](https://www.cadence.com/en_US/home/tools/system-design-and-verification/formal-and-static-verification/jasper-gold-verification-platform.html) from Cadence and [PrimeTime](https://www.synopsys.com/implementation-and-signoff/signoff/primetime.html) from Synopsys in Lab-8. Finally, the UMC 0.18um Mixed Signal (1P6M) CMOS fabrication process data is provided from [Taiwan Semiconductor Research Institute](https://www.tsri.org.tw/) (TSRI).

## To Run the Workflow in a Lab

1. Register-transfer level (RTL) simulation  
``` console
$ ./01_run
```
2. Synthesis (RTL to Gate)  
``` console
$ ./01_run_dc
```
3. Gate-level simulation  
``` console
$ ./01_run_gate
```
4. Generate memory model  
   *refer to lab-5*
     
5. Automatic Placement and Routing (APR)  
```console
$ ./00_combine_apr
$ ./01_run_apr

*next refer to lab-11*  
```
6. Post simulation  
```console
$ ./01_run_post
```

## Acknowledgement

&emsp;&emsp;首先，非常感謝維尼學長提供的超強 pattern (請放心，我並沒有放在這裡)，在這一學期以來，我承受著來自實驗室、IC lab、日常生活的多方壓力，頂著這樣嚴苛的條件下，有好幾次 lab 都只能是多虧了有學長的 pattern 我才能將寶貴的時間專注於 design 上，而不必負擔額外的心力用於撰寫 pattern，您絕對是讓我能順利通過這門課的最大恩人，再次萬分感謝！接下來我還要感謝 ICICLAB 十人群組的各位，幾次的魔王級 lab 以及 project 都是靠著大家的互相討論與合作才有辦法度過難關，也謝謝大家在我偶爾問出白癡問題時對我的包容。另外我還要特別感謝我的室友 [Yahooyuan](https://github.com/Yahooyuan)，對於在一起修課的這一學期以來無數次的討論與提點。最後肯定還是要感謝本學期負責規劃與 demo 所有 lab、project 的助教們，要完整架構出一整個 lab 的內容確實是十分不容易的工作，各位助教辛苦了謝謝你們。衷心感謝以上各位，有了你們才能有如今的我，謝謝大家！  
