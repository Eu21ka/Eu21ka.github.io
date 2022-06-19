---
title: embryoio level4~level14
date: 2022-06-11 13:13:46
tags:
- pwn
categories:
- [刷题, pwncollege刷题日记]
---

# embryoio level4

## 题目简介

学会环境变量配置



## 解题流程

### 运行程序

![image-20220608195228374](image-20220608195228374.png)

根据题目要求可以知道检查机制是需要一个名叫`dgixih`的环境变量，而且这个环境变量的值必须等于`itrtudurhb`。



### 编辑环境变量并运行

可以去配置文件里用export写入或者直接用`evn`指令，不会的可以去搜一下，所以使用以下指令可以直接获得flag。

```shell
$ env -i /challenge/embryoio_level4
```



# embryoio level5

## 题目简介

关于Linux重定向



## 解题流程

### 运行程序

![image-20220608200419783](image-20220608200419783.png)

由上图可知检查机制是需要一个外部文件作为外部输入，但这个文件的内容是什么我们还不知道。



### 创建外部文件并重定向

既然不知道文件的内容，就按照提示在对应目录下创建个空文件。

![image-20220608200921015](image-20220608200921015.png)

然后使用以下指令重定向运行程序：

```shell
$ /challenge/embryoio_level5 < /tmp/myjker
```



### 填写密码并再次运行

![image-20220608201105657](image-20220608201105657.png)

可以看到输出了新提示，他说需要一个简单密码，并且密码也给了我们，所以就按照提示使用`vi或者vim指令`将密码写入刚刚创建的外部文件里，保存后再次使用之前的指令运行就得到了flag。



# embryoio level6

## 题目简介

关于Linux重定向



## 解题流程

### 运行程序

![image-20220608201808574](image-20220608201808574.png)

这里告诉我们需要一个外部文件来接受他的输出，所以我们按照要求创建文件。



### 执行程序并查看文件

![image-20220608202102202](image-20220608202102202.png)

我们可以看到利用指令运行后并没有出现新的提示和flag，所以猜测flag就输出在我之前创建的文件中，使用`cat`指令查看一下刚才创建的文件。

![image-20220608202251079](image-20220608202251079.png)

发现输出了一推，并且flag就在里面。



# embryoio level7

## 题目简介

关于Linux环境变量



## 解题流程

### 运行程序

![image-20220608202512164](image-20220608202512164.png)

可以看到条件里需要一个空的环境变量，但是我们现在有13个。



### 设置新的空环境变量并运行

13个环境变量一个个删肯定不是个好方法，这里就需要`env`指令和`-i`参数，不清楚的可以百度去了。当然，程序得在新的空环境变量当中运行，所以使用以下指令就能获得flag

```shell
$ env -i /challenge/embryoio_level7
```



# embryoio level8

## 题目简介

关于shell脚本



## 解题流程

### 运行程序

![image-20220608203332533](image-20220608203332533.png)

可以看到程序必须是被一个shell脚本运行的，所以将执行语句`/challenge/embryoio_level8`写入`my_script.sh`脚本文件即可。



### 编写脚本并运行

使用`touch my_script`指令创建该名字的脚本文件，再将执行语句写入到脚本文件中，保存后并用`bash my_script.sh`指令执行，便得到了flag。



# embryoio level9~level14

## 题目简介

关于shell脚本



## 解题流程

后面的题其实和之前的题差不多，无非就是将shell指令写入脚本文件中，然后`bash`执行。只是后面的题目不同的是`my_script.sh`文件中并不单单只是一个运行指令，还需要加上一些题目条件。至于如何得到题目条件，只需要先用脚本运行一次程序，然后程序就会输出缺少的条件。这里就不一一赘述，下面是各题的脚本。

### my_script.sh

```sh
/challenge/embryoio_level9		#运行后需要输入密码，直接从shell指令中输入就行
/challenge/embryoio_level10 lswcraneju		
env ugdygr=ybezdhyzoq /challenge/embryoio_level11
/challenge/embryoio_level12 < /tmp/vkkrve		#首先创建外部文件，但是里面需要有个密码，程序提示会给出
/challenge/embryoio_level13 > /tmp/lxhgyi		#flag会输出在该外部文件中
env -i /challenge/embryoio_level14		
```



