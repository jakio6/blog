ngspice入门教程
===
> http://ngspice.sourceforge.net/ngspice-tutorial.html#intro

介绍
---
ngspice是一个电路仿真软件,可以对方程形式描述的电路(有源和无源器件组成)进行处理.
模拟时变电流和电压以及噪声和小信号行为.ngspice是来加州大学伯克利分校的spice3f5的
开源继承者.

![图表1](http://ngspice.sourceforge.net/tutorial-images/intro1.png)

如同图表1(图没复制了)中的那样. 你需要创建一个描述这个电路的网络列表. 这个网络列
表是ngspice的输入, 告诉它要模拟的电路. 其中夹杂着一些用于读取和解析网络, 开始模
拟,和plotting输出的模拟命令. 输出电压(以红色绘制)和输入电压是相反的(针对这个电路
). 都是电压对时间的关系.

ngspice的输入是从一个文件中读取, 可以通过命令行中提供的命令来补充. 模拟输出可以
写入到一个文件, 或者以y-x图形或者smith chart的形式plot. 没有带有电路图和自动网表
生成的图形界面,但是有可以用于绘制电路并生成ngspice电路的第三方工具.

ngspice有一个详细的参考手册. 这个手册描述了ngspice中可用的所有命令和过程并且给出
了许多的例子. 但是,它不是一个ngspice-howto或者介绍性文本. 这个教程会给你提供一点
如何开始的信息. 如果你想要更深入地了解, 可以参考我们的书籍页和[第三方教程列表
](http://ngspice.sourceforge.net/tutorials.html)

安装过程略

带有无源器件的电路, 工作点
---
现在来试一下第一个电路. 需要一个dc电源以及两个电阻来构建一个简单的电阻分压器

![图表3](http://ngspice.sourceforge.net/tutorial-images/fig3.png)

这个电路的网表是什么呢? 电源连接到0和节点in,值是1(电压?), 在in和out之间的R1电阻
值为1k,在out和地之间的R2值为2k
```
voltage divider netlist
v1 in 0 1
r1 in out 1k
r2 out 0 2k
.end
```
第一行是一个标题行,在第五行的.end标注网表的结束.将这些文本行复制到一个文本文件
test.cir. 运行费ngspice并加载它:
```
ngspice test.cir
```
现在ngspice已经可以进行模拟了,网表已经加载了. 我们想要进行哪种类型的模拟呢? 感兴
趣的是节点out的DC电压. 这个是这个电路的操作点(operating point,什么东西?). 我们需
要通过键入`op`命令来获得. 然后我们就会得到节点out处的电压值. 键入`print out`命令
.这是完整的ngspice输出序列?你会看到节点out的电压.
```
➜  ngspice test.cir
******
** ngspice-30 : Circuit level simulation program
** The U. C. Berkeley CAD Group
** Copyright 1985-1994, Regents of the University of California.
** Please get your ngspice manual from http://ngspice.sourceforge.net/docs.html
** Please file your bug-reports at http://ngspice.sourceforge.net/bugrep.html
** Creation Date: Fri Jan 11 08:14:29 UTC 2019
******

Circuit: voltage divider netlist

ngspice 6 -> op
Doing analysis at TEMP = 27.000000 and TNOM = 27.000000



No. of Data Rows : 1
ngspice 7 -> print out
out = 6.666667e-01
ngspice 8 -> 
```

带有无源器件的电路,瞬态模拟
---
接下来这个例子是双rc ladder, 我们想要进行瞬态仿真. 输入是一个电压对时间波形(或者a
pulse), 输出也是一个波形, 如同你在示波器上会看到的一样. 这是电路:

![图表4](http://ngspice.sourceforge.net/tutorial-images/fig4.png)

对应的网表是:
```
.title dual rc ladder
r1 int in 10k
v1 in 0 dc 0 pulse(0 5 1u 1u 1u 1 1)
r1 out int 1k
c1 int 0 1u
c2 out 1 100n
.end
```

我们需要讨论电源v1. 在前面的例子中,它只是一个1v的常量. 现在它更加复杂了. 手册
4.1.1节说到. 要获得一个脉冲我们需要将pulse(vl vh td tr tf pw per phase) 添加到我
们的电压源的DC电压,vl是开始, vh是结束电压,td是时延,tr和tf是上升和下降时间, pw是
脉冲宽度,per重重复的周期, phase是相移. 我们有一个从0到5v的脉冲,脉冲开始前的时延,
上升和下降时间都是1us. 脉冲宽度和脉冲周期都是1s,远远超出我们的模拟时间. phase在
这里不重要,省略他,因此这里值用到脉冲的上升沿.

现在我们需要的模拟时间是多少? 我们的低通滤波器的时间常数由r1c1控制,大约是
`1uF*10kOhm = 10ms`,因此我们从0开始模拟到50ms就好了. 我们要使用1000个点,因此step
size是50us.因此.当你加载这个电路之后, 现在要使用的模拟命令是`tran 50u 50m`

在使用命令`plot in int out` plotting之后的结果如图表5. 在节点int和out的电平稍微
有点不同. 这是因为第一个r1rc控制电路. 第二个r2c2的时间常数比它小100倍, 因此给c2
充电的时间相比于c1要快得多. 输入节点int处的电压上升得太快了,都看不到斜率.

![图表5](http://ngspice.sourceforge.net/tutorial-images/fig5-2.png)

带有无源器件的电路, 小信号AC仿真
---
现在我们想要看一下这个rc ladder网络的小信号行为是怎么样的. 小信号意味着我们给我
们的电路设置一个dc操作点. 然后将一个小ac信号加到输入并且模拟. 我们对输出电压的绝
对值不敢兴趣, 而只关心它与输入(增益)的关系以及它相对输入(相位)的相移. 幸运的是
,ngspice中有一个ac命令,makes life easy. 首先需要告诉ngspice到哪里输入他们的小信
号ac电平. 我们选择节点in, 也就是我们的电压源v1, 现在v1变成了:
```
v1 in 0 0 ac 1 pulse(0 4 1u 1u 1u 1 1)
```
我们就只是加入了`ac 1`,`dc 0`设置操作点(由于我们电路简单,没有影响). pulse只在瞬
态模拟期间有影响, 直接保留它好了.`ac 1`中的1只能帮助我们获得比率out/in..这里需要
的模拟命令是:
```
ac dec 10 1 100k
```
我们想要进行ac模拟. 我们以类似对数绘制的形式改变频率,with 10 points per decade.
起始频率是1hz,终止频率是100khz. 因此我们仍然你得到51个数据点. 如果现在使用命令
`plot out`绘制出来,图形看起来会很丑. 我们在处理ac信号. 这些是复数, 由实部和假想
的虚部构成(或者等价的幅度和相移). 同行`plot out`只绘制信号的实部部分. 但是我们想
要看到幅度(或者增益)和相位,就像bode plot一样. 因此,应该要使用`plot vdb(out)`来获
得dB为单位的增益以及`plot ph(out`来获得相位. 想在图像看起来ok了, 但是标题和label
还不尽如人意.这里的ngspice绘图程序需要一些手动调整.

但是,在继续之前,我们需要简化我们的approach. 所有的东西都在终端中键入太烦人了,
ngspice有一个将所有交互命令(我们键入的)给封装到一个`.control .endc`区域的机制.
这个`.control`区域可以加入到网表中,看起来像这样:
```
.title dual rc ladder
* file name rcrcac.cir
R1 int in 10k
V1 in 0 dc 0 ac 1 PULSE (0 5 1u 1u 1u 1 1)
R2 out int 1k
C1 int 0 1u
C2 out 0 100n

.control
ac dec 10 1 100k
plot vdb(out)
plot ph(out)
.endc

.end
```

现在我们可以使用`ngspice rcrcac.cir`来启动ngspice. 网表会被读取,`.control`区域中
的命令(ac模拟和绘制)会自动执行. 我们还需要优化图形输出. 可以使用一些额外的命令实
现,也加入到`.control`区域中. 这些在ngspice手册17.5节中都有介绍,现在整个的输入文
件是这样的:
```
.title dual rc ladder
* file name rcrcac.cir
R1 int in 10k
V1 in 0 dc 0 ac 1 PULSE (0 5 1u 1u 1u 1 1)
R2 out int 1k
C1 int 0 1u
C2 out 0 100n

.control
ac dec 10 1 100k
settype decibel out
plot vdb(out) xlimit 1 100k ylabel 'small signal gain'
settype phase out
plot cph(out) xlimit 1 100k ylabel 'phase (in rad)'
let outd = 180/PI*cph(out)
settype phase outd
plot outd xlimit 1 100k ylabel 'phase'
.endc

.end
```
模拟和绘制之后看到的是:

![图表6](http://ngspice.sourceforge.net/tutorial-images/fig6.png)

下载和安装一个简单的GUI(windows??!!)
---
..

双极放大器
---
下一个例子是一个双极放大器. npn双极晶体管bc546是放大器件. 两个电阻r1,r2确定基极
电流. r3是dc负载电阻. rload是必要的,因为ngspice不接受终端处没有dc连接的电容??
vcc是供电电源,vin是输入电源.

![图表8](http://ngspice.sourceforge.net/tutorial-images/fig8.png)

即使将所有的设备按照上面这样组装,这个电路还是不完整. 晶体管q1要进行模拟还需要更
多数据. 双极放大器模型(计算电流的方程作为端电压函数)在ngspice中是硬编码的. 这个
模型需要一些模型参数来使得这个计算是特定于选中的晶体管(BC546)的. 这些不是和
ngspice一起提供的. 它们是特定于设备制造商的, 可以从他们的网站或者其他网站获得.
最后得到的是什么呢?
```
.model BC546B npn ( IS=7.59E-15 VAF=73.4 BF=480 IKF=0.0962 NE=1.2665
+ ISE=3.278E-15 IKR=0.03 ISC=2.00E-13 NC=1.2 NR=1 BR=5 RC=0.25 CJC=6.33E-12
+ FC=0.5 MJC=0.33 VJC=0.65 CJE=1.25E-11 MJE=0.55 VJE=0.65 TF=4.26E-10
+ ITF=0.6 VTF=3 XTF=20 RB=100 IRB=0.0001 RBM=10 RE=0.5 TR=1.50E-07)
```
以`.model`开始的一行, 跟对应的名称BC546B以及设备类型,也就是npn晶体管.在括号中有
所有的model参数,与硬编码的模型一起,就构成了晶体管的dc,ac,transient以及噪声行为.
这些行可能都在一行中, 为了可读性,你可能想要将它拆分成多个行. 每个续接的行需要由+
开始. ngspice内部会将这些续接行整合到单行中. 最终的网表是:
```
bipolar amplifier
* file bipamp.cir
.model BC546B npn ( IS=7.59E-15 VAF=73.4 BF=480 IKF=0.0962 NE=1.2665
+ ISE=3.278E-15 IKR=0.03 ISC=2.00E-13 NC=1.2 NR=1 BR=5 RC=0.25 CJC=6.33E-12
+ FC=0.5 MJC=0.33 VJC=0.65 CJE=1.25E-11 MJE=0.55 VJE=0.65 TF=4.26E-10
+ ITF=0.6 VTF=3 XTF=20 RB=100 IRB=0.0001 RBM=10 RE=0.5 TR=1.50E-07)
R3 vcc intc 10k
R1 vcc intb 68k
R2 intb 0 10k
Cout out intc 10u
Cin intb in 10u
VCC vcc 0 5
Vin in 0 dc 0 ac 1 sin(0 1m 500)
RLoad out 0 100k
Q1 intc intb 0 BC546B
.tran 10u 10m
*.ac dec 10 10 1Meg
.end
```

`.model`直接直接与q1行对应,现在它提供了必要的模型参数.`.tran 10u 10m`引入了一个
新的元素,一个dot命令. 在你想要以脚本模式运行ngspice的时候很有用. 下一行`*.ac dec
10 10 1Meg`前缀有`*`. 这是用于注释行的. 每一个由`*`开始的行都被视为注释, 在模拟
期间会被忽略. 防止`*`允许选择一个模拟类型???

再在输入文件中加上`.control`部分:
```
.control
run
gnuplot gp v(out) v(in)
.endc
```
然后运行ngspice
> 我觉得你小子就是想诱惑我用gnuplot,可是为什么只能通过xterm调用呢? 不能改吗?

带OpAmp的反向放大器
---
最后一个例子是使用运算放大器lf356的一个反向放大器. 它的增益有r2对r1的比率控制.
这个放大器反转输出极性. 因此输出是`v(out) = -r2/r1 * v(in) = -100 * v(in)`

![图表10](http://ngspice.sourceforge.net/tutorial-images/fig10.png)

ngspice不带OpAmps的model. 因此你需要在网上索索对应制造商的model, 比如从TI的网站
下载.... 从espice spice model页以及它的子目录可以获得自2000年以来的大量分立期间
和IC模型.

如果你看了lf356.mod文件的话,你会发现封装在一个名称lf356/ns,有五个连接节点的子电
路中的电路(在`.subckt`和`.ends`之间(为什么我没有看到??))

怎么将lf356 model添加到ngspice网表中呢? 将lf356复制到包含网表OpAmd.cir的的目录中
. 在OpAmp.cir中添加一行`.include LF356.mod`

怎么在网络列表中调用model呢? 这个是通过X行实现的(见manual 2.4章),比如`XU1 3 2 7
4 7 LF356/NS`. 引脚数量对应IC数据手册中给出的引脚数目. 我们决定使用引脚数目作为
这个网表的节点名称. 也可以选择其他的网络名称(比如电路引脚名). 电路引脚名 / 引脚
号 对是: in- / 2, in+ / 3, v+ / 7, v- / 4, 以及out / 6. model需要一个顺序:
- 非反向输入
- 反向输入
- 供电电源正极
- 供电电源负极
- 输出
, 如同在model文件中描述的. 因此X行中的节点需要按照这个顺序组织,也就是3 2 7 4 6.
完整的网表是:
```
.title Inverting OpAmp amplifier
*file OpAmp.cir
.include LF356.MOD
XU1 3 2 7 4 6 LF356/NS
R1 2 in 1k
Vin in 0 dc 0 ac 1
Vp 7 0 5
Vm 4 0 -5
Vin+ 3 0 0
R2 6 2 100k
.end
```

这次我们想要进行dc模拟, 就是,我们通过略微上升的直流电压改变输入并且测量输出.要知
道的是电源提供+-5v, 因此输出不能比这个大, 并且放大系数是-100. 因此我们, 使用命令
`dc vin -50m 50m 2m`来从从-50mv到50mv以2mv的步进值改变vin. 也可以在网表中加入命
令`.dc vin -50m 50m 2m`或者添加`.control`区域

![图表11](http://ngspice.sourceforge.net/tutorial-images/fig11.png)

输入电压的变化几乎看不见. OpAmp输出已经在+-3v饱和, far away from rail-to-rail
+-5 V which is possible with modern OpAmps.

<!-- 2019-07-11 22:42 -->
<!-- bye -->
