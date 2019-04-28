<!-- 也许应该把原始链接贴上 -->
- [origin](http://www.science.unitn.it/~fiorella/guidelinux/tlk/node94.html)
# 文件系统

这一节介绍linux内核如何维护其支持的文件和文件系统. 介绍了VFS虚拟文件系统以及linux内核的
实际文件系统的支持

linux许多重要的特性中的一个就是,它支持多个不同的文件系统. 这使得它非常灵活,并且能够和其他
许多操作系统共存. linux支持15中文件系统的写...还会加

在linux中,就像unix那样,系统使用的单独的内文件系统可能不会被设备标识符访问( 比如一个驱动器号
或者一个驱动器名),而是混合到一个树形结构中, 整个文件系统以一个实体的形式存在. linux通过挂载的
方式来讲文件系统加到这个文件系统树中. 所有的文件系统, 不论何种类型, 都挂载到一个目录中并且
挂载的文件系统中会遮盖那个目录的内容. 这个目录即是挂载目录,或者挂载点. 当文件系统卸载之后,
挂载目录的内容又会出现


在磁盘初始化后,其上会增加一个将物理磁盘划分到一定数量的逻辑分区的分区结构. 每一个分区都可以
拥有文件系统,比如ext2. 文件系统将文件组织为目录,软链接等等的逻辑层次结构.包含文件系统的设备
叫做块设备. IDE磁盘分区/dev/hda1,第一个IDE磁盘驱动的第一个分区,是一个块设备. linux文件系统
将这些块设备当做块的线性集合, 而并不关心磁盘的底层形式. 需要由块设备驱动来讲读写特定块的请求
映射为对其对应的设备有意义的形式,给定块保存的磁道,扇区,和柱头. 文件系统甚至可以不在本地系统中.

linux最初的minix文件系统限制颇多, 92年引入ext文件系统,但是性能仍旧不足. 因此在93年添加了ext2.
也是这一章要详细介绍的

在ext文件系统添加到linux的时候正在进行一项非常重要的开发. 实际的文件系统通过VFS接口从操作系统
和系统服务中分离开来. VFS允许linux支持许多不同的文件系统,每一个文件系统都呈现给VFS一个统一的接口.
所有的细节都由软件转换,因此所有的文件系统呈现给内核剩下部分和运行在系统中的程序的形式都是一致的.
linux的虚拟文件系统允许同时挂载许多不同的文件系统.

linux虚拟文件系统追求对其文件尽可能快和高效的访问,同时还必须保证文件和其数据正确保存. 这两个要求
可能是相互矛盾的. linux VFS在每个文件系统挂载的时候会在内存中缓存信息.xxxx

## ext2文件系统
```
(block group( super block, group descriptors, block bitmap ,inode bitmap , inode table, data block))*
```

ext文件系统由xx创建. 它也是linux社区中目前最成功的文件系统,并且是当前所有的linux发行版本的基础

ext2文件系统和许多其他的文件系统一样,都是建立文件保存在数据块中的前提下的. 这些数据块都是相同
长度的,虽然在不同的ext2文件系统中这个长度可能不同(在创建的时候确定的). 每一个文件的大小都向上取到
一个整块. 这意味着平均每个文件会浪费半个块. 通常在计算中你需要权衡内存和和磁盘利用率. linux和许多
文件系统都选择使用相对低效的磁盘使用量来减少cpu的工作量. 文件系统中不是所有块都是用来存放数据的.
ext2定义了使用inode数据结构来描述每个文件的拓扑结构. 一个inode描述了文件数据占据了哪些块,以及文件
的访问权限,修改时间和类型. ext2文件系统中的每一个文件都是由一个inode描述的,每一个inode由一个唯一的编号.
整个文件系统的inode都保存在一个inode表中. ext2目录是一个特殊文件(也是由inode描述的),其包含指向其目录内
条目的inode

## ext2 inode

```
(mode , owner , size ,timestamps , data blocks(data *) ,indirect blocks ( xx(data) ), double indirect(xx ( xx (data)), triple(..))
```

在ext2文件系统中,inode是基础的用于构建的block, 每个文件和目录都是由一个inode唯一指定的. 每一个block group中的
inodes都是一同保存在一个inode表中,使用bitmap,使得系统可以保持对分配的和未分配的inode的跟踪.

- mode: 保存两段信息, 这个inode描述什么(类型),权限
- owner info : 文件的用户和组
- size : 字节数
- timestamp : 创建时间和最后修改时间
- datablocks : 指向inode描述的数据的块的指针.前12个是指向物理块的.最后的是三个是包含更多级的重定向的指针.

ext2可以描述特殊设备文件. 这些文件不是实际文件,但是文件可以通过其来访问设备. /dev下所有的设备文件都允许程序访问linux的设备..

## super block
superblock包含对这个文件系统的basic size和shape的描述. 其中的信息允许文件系统管理器来使用和维护文件系统.
通常在文件系统挂载的时候只有block gourp 0中的superblock会读取.但是每一个block group都包含一份副本.
其中包含一下信息:
- magic number : 供挂载软件检查以便判断这个superblock是不是ext2的superblock. 当前版本的ext2是0xef53
- revision level : 
..
- 挂载统计和最大挂载统计
- block group number
- 块大小
- block per group
- free blocks
- free inodes
- first inode

## group descriptor

每一个block group都有一个描述它的数据结构. 就像superblock一样,block group中的所有group
descriptor都有副本

- block bitmap
- indoe bitmap
- inode table
- free block count ,free inode count, used directory count

..

## directory

在ext2文件系统中目录是用于创建和保存到文件系统中文件路径的特殊文件.目录文件是一个目录条目的列表,
每一个都包含一下信息
- inode : 这个目录条目的indoe.这个是保存这个inode的数组中的索引
- 名称长度
- 名称

每个目录的前两个条目都是标准的`.`和`..`,表示当前目录和父目录

## 在ext2文件系统查找文件
..

## 改变文件大小

文件系统的常见问题是分段的倾向. 保存文件的数据的块散布在整个文件系统中,这使得顺序访问文件变得
的效率却来越低,数据块的距离越来越远. ext2文件系统试图通过给文件分配物理接近的块来客服这个问题..

...

<!-- 2019-04-20 20:06 -->
