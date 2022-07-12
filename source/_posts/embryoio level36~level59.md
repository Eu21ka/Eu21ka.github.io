---
title: embryoio level36~level59
date: 2022-07-12 20:07:00
tags:
- pwn
categories:
- [刷题, pwncollege刷题]
---

# embryoio level36~level47

## 题目简介

Linux终端和shell脚本的管道符使用



## 解题流程

### 运行程序

![image-20220712132719498](/image-20220712132719498.png)

它显示需要我们去接收程序的输出流，而且下面有说需要用管道，所以指令后面加上管道接其它指令即可。



### shell指令

```shell
/challenge/embryoio36 | cat

/challenge/embryoio_level37 | grep 'pwn' #取关键字

/challenge/embryoio_level38 | sed '1d'	#删除第一行

/challenge/embryoio_level39 | rev | rev	#两次取反就正常输出了

cat | /challenge/embryoio_level40	#再输入密码获得flag

rev | rev | /challenge/embryoio_level41	#两次取反后直接输入密码获得flag（可能输入密码后需要按ctrl+d flag才会出现）

#以下指令要写入shell脚本中，再bash运行shell脚本
/challenge/embryoio_level42 | cat

/challenge/embryoio_level43 | grep 'pwn'

/challenge/embryoio_level44 | sed '1d'

/challenge/embryoio_level45 | rev | rev

cat | /challenge/embryoio_level46

rev | rev | /challenge/embryoio_level47	#直接输入密码获得flag（可能输入密码后需要按ctrl+d flag才会出现）
```



# embryoio level48~level59

## 题目简介

python脚本中的管道使用



## 解题流程

### 运行程序

![image-20220712135029230](/image-20220712135029230.png)

可以看到需要让我们用python运行



![image-20220712135209976](/image-20220712135209976.png)

编写python脚本运行后又出现需要管道接收输出的提示。



### python脚本

```python
#===============================level48===============================
from pwn import *
io1 = subprocess.Popen('/challenge/embryoio_level48', stdout=PIPE)
io2 = subprocess.Popen('cat', stdin=io1.stdout, stdout=PIPE)
output = io2.communicate()[0]
print(output)

#===============================level49===============================
from pwn import *
io1 = subprocess.Popen("/challenge/embryoio_level49", stdout=PIPE)
io2 = subprocess.Popen(['grep', 'pwn'], stdin=io1.stdout, stdout=PIPE)
output = io2.communicate()[0]
print(output)

#===============================level50===============================
from pwn import *
io1 = subprocess.Popen("/challenge/embryoio_level50", stdout=PIPE)
io2 = subprocess.Popen(['sed', '1d'], stdin=io1.stdout, stdout=PIPE)
output = io2.communicate()[0]
print(output)

#===============================level51===============================
#将逆序的flag复制到文本里，再rev输出
from pwn import *
io1 = subprocess.Popen("/challenge/embryoio_level51", stdout=PIPE)
io2 = subprocess.Popen('rev', stdin=io1.stdout, stdout=PIPE)
output = io2.communicate()[0]
print(output)

#===============================level52===============================
#运行后输入密码获得flag
from pwn import *
io1 = subprocess.Popen('cat', stdout=PIPE)
io2 = subprocess.Popen("/challenge/embryoio_level52", stdin=io1.stdout)
output = io1.communicate()[0]
print(output)

#===============================level53===============================
#运行后逆序输入密码获得flag
from pwn import *
io1 = subprocess.Popen('rev', stdout=PIPE)
io2 = subprocess.Popen("/challenge/embryoio_level53", stdin=io1.stdout)
output = io1.communicate()[0]
print(output)

#===============================level54~level59===============================
#又是一遍“十万年轮回”，题目和上诉题目差不多，题解参考上诉脚本。
```

