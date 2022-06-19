---
title: ISCC 2022 MISC2
date: 2022-06-019 22:19:11
tags:
- misc
categories:
- [比赛，2022ISCC]
---

打开压缩包，里面有一张图片

![img](/wps7.jpg) 

是一张魔女的图片，放入kali中foremost分离，分离出了另一张图片

![img](/wps8.jpg) 

 

对这张图片进行zsteg的操作，首先zsteg -a查看lsb的各项数据

![img](/wps9.jpg) 

 

在这里发现了点东西，接着就是使用zsteg -E了

zsteg -E b1,r,lsb,yx 该图片名称.png > out.png

得到out.png

根据刚下载下来的时候的魔女图片想到这应该是魔女之旅的字体

![img](/wps10.jpg) 

![img](/wps11.jpg) 

根据out.png上面的字对应上方两张图片的字体，按照题目的要求变成ISCC{xxxx-xxxx-xxxx}的格式（需要全部大写）就是答案了

 