# 介绍
介绍如何找到符合你指定的文件,以及如何对你找到的文件执行多种操作


## 概览
用于创建指定要求的文件列表并且对其进行操作的主要程序有find ,locate, xargs. 一个额外的额updatedb用于系统管理员创建
给locate使用的数据库

find在一个目录层级中查找文件并打印其找到的文件的信息

locate在特殊的数据库文件中查找匹配模给定模式的文件名. 系统管理员运行updatedb程序来更新这个数据库

xargs用于组合参数. xargs在其标准输入读取参数来构建并执行命令. 通常,这些参数是find生成的文件名列表.

## find表达式
find用来选择文件的表达式由一个或者多个初级选择构成,每一个find的一个单独的命令行参数. find在每次处理一个文件的时候都会
计算这个表达式. 表达式可以包含下面这些类型的原语 :
- 选项: 影响所有的操作
- 测试: 返回true或者false,取决于文件属性
- 行为: 有副作用并且返回一个true或者false值
- 操作符: 连接其他参数并且在其求值的时间和参数

可以缺省两个原语之间的操作符,默认是`-and`.如果表达式不包含除`-prune`之外的行为,会对所有的文件满足表达式的文件会执行`-print`操作

选项立即生效, 而不是在求值中遇到的时候再求值. 因此,为了直观,最好将他们放到放到表达式的开头. 有两个例外,`-daystart`和`-follow`
在命令行中不同的位置有不同的意义..这个会非常让人困惑,因此最好在一开始就记住这个

许多原语都接收参数,一一些参数是文件名,模式,或者其他字符串,其他的是数字,数值参数可以像这样置顶:
- `+n`: 大于n
- `-n`: 小于n
- `n` : 等于n

# 查找文件
默认,find会将匹配给定策略的文件名称打印到标准输出

## 名称
搜索名称匹配制定模式的文件的方式.这些测试都有大小写敏感和大小写不敏感的版本

### 基本名称模式
- test: `-name pattern`
- test: `-iname pattern` : 在文件的base名称匹配shell模式pattern的时候为true,带i的大小写不敏感,注意通配符应该要引用以避免被shell展开

### 全名称模式
- test: `-path pattern`
- test: `-wholename pattern` : 匹配则为true,以`/`结束的`-path`参数什么都不会匹配

- test: `-ipath...`

- test: `-regex expr`
- test: `-iregex expr` : 如果整个文件名匹配正则表达式则为true

- option: `-regextype name` : 选择使用的正则表达式风格
	- emacs,posix-awk,posix-basic,posix-egrep,posix-extended
### 快速全名称搜索
要快速搜索通过名称搜索文件而不实际扫面磁盘中的目录,可以使用locate程序.

`locate pattern` 等价于 `find directories -name pattern`

## 链接

- `-L`,跟进连接
- `-P`,不跟进连接,(默认)
- `-H`,跟进命令行中的连接

- test: `-lname pattern`
- test: `-ilname pattern` : 文件是内容匹配shell模式的符号连接时为true

- test: `-samefile NAME` : 和NAME同一个inode的文件,指定`-L`的时候还会匹配匹配指向NAME的文件
- test: `inum n` : 有n个inode的文件,可以使用+,-
- test: `-links n`: n个链接

## 时间
每一个文件有三个时间戳;
- a访问时间(读取文件内容
- c状态改变(修改文件或属性)
- m修改(改变文件内容)

- test: `-atime n`
- test: `-ctime n`
- test: `-mtime n` : n x 24小时之前

- test: `-amin n`
- test: `-cmin n`
- test: `-mmin n` : n 分钟之前

- option: `-daystart` : 从一天开始的时候开始度量时间,而不是24小时之前

- test: `-newerXY reference` : 文件的X比ref的Y新则为true
- test: `-anewer file`
- test: `-cnewer file`
- test: `-newer file` : a,c,m时间比file最后modified新

- test: `-used n` : 在文件c之后n天后a了则为true

## 大小
- test: `-size n[bckwMG]` : 如果文件使用了n个空间单元,向上舍入. 默认的单元是512字节块(b),c,w,k,...
- test: `-empty` : 文件是空的,并且是普通文件或者目录

## 类型
- test: `-type c` : 文件是c类型的时候为true( bcfpfls)
- test: `-xtype c` : 在文件不是符号连接的时候和`-type`一致

## 所有者
- test: `-user uname`
- test: `-group gname` : 所有权正确时为true,允许数值id

- test: `-uid n`
- test: `-gid n` : ...支持+,-

- test: `-nouser`
- test: `-nogroup` : ...

## 文件模式位
- test: `-readable`
- test: `-writable`
- test: `-executable`
- test: `-perm pmode`
- test: `-context pattern` : SELinux contex匹配pattern的时候为true

## 内容
搜索文件内容可以使用grep..

如果还想要搜索子目录中的文件中的字符串,可以混合使用grep find 和xargs:
```
     find . -name '*.[ch]' | xargs grep -l thing
```
grep 的`-l`选项只打印包含字符串的文件名称

## 目录
如何控制find搜索哪些目录,以及如何搜索
- option : `-maxdepth levels`: 最多下降levels层,0表示只对命令行参数应用test
- option : `-mindepth levels`: 对level小于levels的目录不进行任何测试.1表示处理除命令行参数之外的所有文件
- option : `-depth` : 目录内容的处理先于目录自身
- action : `-prune` : 如果文件是目录,不进入它..
- action : `-quit` : 立即退出
- option : `-noleaf` : ..
..

## 文件系统
文件系统磁盘的一个区间.
- option : `-xdev`
- option : `-mount` : 不进入其他文件系统的目录

- test : `-fstype type` : 文件位于type类型的文件系统时为true

## 使用操作符组合原语
- `(expr)`, 强制优先级
- `!expr`
- `-not expr` : not
- `expr1 expr2`
- `expr1 -a expr2`
- `expr1 -and expr2` : 与
- `expr1 -o expr2`
- `expr1 -or expr2` : 或
- `expr,expr2` : 两个都总是会求值,在第二个为真的时候为真

- test: `-true` : alway true
- test: `-flase` : always false

# actions

print infomatio about the files that match the criteria you gave in the find expression

## run commands

use the list of file names created by find or locate as arguments to other commands..
### single file
- action : `-execdir command ;`
takes all the arguments after `-execdir` until `;` as the command , replace '{}' by the current file name ??

- action : `-exec command ;`
insecure variant of the `-execdir` action, main difference is , the command is executed in the directory from which find is invoked..

eg:
```
[jakio6@jakio6-pc ~]$ find -name test.c -execdir echo '{}' \;
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
./test.c
^C
[jakio6@jakio6-pc ~]$ find -name test.c -exec echo '{}' \;
./test.c
./git/babystep/os/lib/test.c
./git/babystep/glibc/test/36/test.c
./git/babystep/codewars/C/test.c
./git/c/test.c
./git/c/socket/test.c
./git/c/utf-8/test.c
./git/linux-4.4.177/lib/raid6/test/test.c
./git/linux-4.4.177/tools/usb/ffs-aio-example/simple/host_app/test.c
./git/linux-4.4.177/tools/usb/ffs-aio-example/multibuff/host_app/test.c
./git/linux-4.4.177/drivers/vhost/test.c
./git/attitude/test.c
./os/lib/test.c
./tmp/test.c
./tmp/grub/grub-core/commands/test.c
./tmp/grub/grub-core/tests/lib/test.c
```

as show in the output up

### multiple files

process files at a time..

- action : `-execdir command {} +` : 就像是前面那个`;`的,除了 {}会展开成匹配文件的名称的列表;
- action : `-exec command {} +` : ...

...

- action : `-okdir ...`
- action : `-ok ...` ...

### xargs
另一种**不是那么安全**对多个文件运行命令的方式, 是使用xargs命令
```
xargs [option...] [command [initial-arguments]]
```

xargs从标准输入读取参数. 这些参数由空白或者换行分隔(可以使用双引号,单引号或者`\`保护). 一次或者多次执行
带initial-arguments的command(默认是echo..),标准输入的空白行会被忽略.如果使用了`-L`选项,trailing的空白表示
xargs应该讲接下来的行作为这一行的一部分??

除了空白分隔的名称,使用find -print0或者find -fprint 0并且有带`-0`或者`--null`选项的xargs处理更加安全.

可以使用shell命令替换来处理参数列表 ...

#### 不安全的文件名处理

由于文件名坑呢会包含引号,反斜杠,空白字符,甚至是换行,使用xargs的默认操作模式来处理他们是不安全的. 但是由于多数文件名
并不包含空白,这个问题不是那么明显..如果你知道不会出现这样的文件名的话,就不用担心

#### 安全文件名处理
下面是如何使得find以一种其他程序不会错误解释的形式输出文件名. 可以使用带`-0`和`--null`选项的xargs来处理这种方式生成的文件名.
- action : `-print0` : 将整个文件名打印到标准输出,后跟一个空白字符
- action : `-fprint file` : 类似`-print0`,但是写入到文件 file,像`-fprint`一行..输出文件总是会创建

使用xargs的`--arg-file`选项:
```
     find / -name xyzzy -print0 > list
     xargs --null --arg-file=list munge
```
...(进程替换)
```
  xargs --null --arg-file=<(find / -name xyzzy -print0) munge
```

#### 文件名中的不寻常字符

...

#### 限制命令大小

xargs提供了控制其每次执行命令的时候传递给它参数的数量. 默认使用最多`ARG_MAX - 2k`或者128k,,,

下面的选项可以修改这些值:
- `--no-run-if-empty`, `-r` : 如果标准输入没有包含非空字符,不运行命令, 默认及时是这样也是会运行,gnu 拓展
- `--max-lines[=max-lines]`,`-L`, `-l`: 每个命令行使用至多max-lines给非空输入行..如果缺省默认是1
- `--max-args=max-args`,`-n` : 每个命令行最多使用max-args个命令行参数
- `--max-chars=max-chars`,`-s` : 每个命令行最多使用max-chars个字符

#### 控制并行性
通常,xargs每次运行一个命令. 这个叫做串行执行,命令连续进行, 一个接一个. 如果想要xargs串行执行, 可以让它这么做
- `--max-procs=max-procs`,`-P` : 一次运行最多max-procs个进程.默认是1,如果是0,会xargs会尽可能多地运行

#### 散步文件名

xargs可以将其正在处理的文件名插入到给定的命令的参数间. 除非你给定选项来限制命令大小,不然这个模式和`find -exec`抑制
- `--replace[=replace-str]`,`-I`,`-i` : 替换initial arguments中的replace-str为从输入中读取的names,还有,未引用的
 空白不会结束参数,输入只会在空白分隔.对于`-i`选项,如果replace-str缺省,默认是'{}',, 

### querying

询问用于是否最单个文件执行命令...
- action: `-okdir command ;`
- action: `-ok command ;`

- `--interactive`,`-p`提示xx

拜拜
<!-- 2019-04-12 21:01 -->
