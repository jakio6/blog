# 引导信息
## 引导信息格式

在进入操作系统之后,EBX寄存器会包含一个Multiboot2信息数据结构的物理地址,bootloader通过其向bootloader传递必要信息.
操作系统可以选择使用或者忽略其中的任意信息,bootloader传递的信息都是建议性的

multiboot信息结构和其相关的子结构可能会被放在任何地方(当然除了内核和引导模块的地方)

## 基本tag结构
引导信息包含一些固定的部分和一系列tag.其开始是8字节对其的.固定的部分格式如下:
```
             +-------------------+
     u32     | total_size        |
     u32     | reserved          |
             +-------------------+
```