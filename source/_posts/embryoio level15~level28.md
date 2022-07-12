---
title: embryoio level15~level28
date: 2022-06-22 21:31:11
tags:
- pwn
categories:
- [刷题, pwncollege刷题]
---

# embryoio level15~level21

## 题目简介

学会编写python脚本运行程序



## 解题流程

### 运行程序

![image-20220622150316738](/image-20220622150316738.png)

根据上图可以知道程序需要一个名叫`ipython`的python脚本来运行程序，我尝试过在`challenge目录`下编写脚本但是权限不允许，所以就在用户根目录下创建`ipython.py`文件。



### 编写python脚本

```python
#=====================level15=====================
import subprocess
subprocess.run(["/challenge/embryoio_level15"])
```

运行后得到flag



## EXP

其它题目的解题方法与之前的题目都大致一样，无非就是让python脚本来完成之前的操作，所以在此不过多赘述，直接放python代码。

```python
#=====================level16=====================
import subprocess
subprocess.run(["/challenge/embryoio_level16"])		#运行脚本后输入密码即可获得flag

#=====================level17=====================
import subprocess
subprocess.run(["/challenge/embryoio_level16"， "password"])		#在password替换为需要外部输入的密码

#=====================level18=====================
import subprocess
subprocess.run(["/challenge/embryoio_level18"],env={'environment':'value'})		#替换未对应的环境变量即可

#=====================level19=====================
import subprocess
import os
file = open("/tmp/filename", 'w')		#fliename替换为对应的外部文件的文件名
file.write('password')					#password替换为题目对应需要的密码
file = open("/tmp/filename", 'r')
subprocess.run(['/challenge/embryoio_level19'], stdin=file)

#=====================level20=====================
import subprocess
import os
file = open("/tmp/filename", 'w')		#fliename替换为对应的外部文件的文件名
subprocess.run(['/challenge/embryoio_level20'], stdout=file)
file = open("/tmp/filename", 'r')
print(file.read())

#=====================level21=====================
import subprocess
subprocess.run(["/challenge/embryoio_level21"],env={})		#设置一个空环境变量
```





# embryoio level22~level28

这些题与上面一样，基本没什么区别，所以在此也不多赘述，可以参考以上的脚本。