---
title: ISCC 2022 MISC4
date: 2022-06-019 22:19:11
tags:
- misc
categories:
- [比赛, 2022]
---

下载附件打开压缩包

![img](/wps15.jpg) 

首先看stream，将其放入winhex

![img](/wps16.jpg) 

猜测它应该是个压缩包，并且缺少了文件头，补上，保存，修改后缀。打开发现要密码。果断看向另外两个文件。修改图片的宽高看看

![img](/wps17.jpg) 

看见了摩斯密码，在线解密

![img](/wps18.jpg)结果显示nothere

再看向flag.txt

![img](/wps19.jpg) 

 

发现应该是有隐藏东西的，应该不是whitespace，可能是snow加密，再回头寻找图片的信息，在lsb有了发现

![img](/wps20.jpg) 

pswd 1998/xx/xx，这里的话是猜测是压缩包密码，然后根据x的个数来猜测总体位数进行压缩包掩码爆破

![img](/wps21.jpg) 

爆破出密码进行解压，用wireshark进行分析，寻找

![img](/wps22.jpg) 

在这里看到了一个mp3，导出

![img](/wps23.jpg) 

在整个音频后端发现了摩斯密码，进行解密：ISCCMISC感觉不像最后答案，提交了发现错误。回到flag.txt，这时候能确定ISCCMISC是有用的，那就试试snow来解密文档

./snow.exe -p isccmisc -C flag.txt

这里的isccmisc需要小写，最后解出来的也就是答案

 