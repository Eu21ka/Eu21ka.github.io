---
title: 2022国赛初赛 misc2 everlasting_night
date: 2022-06-019 22:19:11
tags:
- misc
categories:
- [比赛]
---

下载附件，是一张图片，拖入winhex并没有太大的发现，后来得到提示以后，仔细看了一下stegsolve中图片的内容。

![img](/wps7.jpg) 

在这里发现了一点线索，于是data extract

![img](/wps8.jpg) 

在这里发现了一串可疑字符串，题目提示，可以配合lsb隐写，那就将这个作为密码，用lsb脚本运行解密（lsb脚本为github的脚本）

https://github.com/livz/cloacked-pixel

![img](/wps9.jpg) 

得到out.txt，拖入winhex看到了PK

![img](/wps10.jpg) 

修改后缀为zip，发现压缩包需要密码，离答案肯定很近了！

这里花了很久，找不到任何东西，发现提示有一句被漏掉了（仔细观察png数据块）

随便找了一张正常的png照片对比了一下

![img](/wps11.jpg) 

这是正常的

![img](/wps12.jpg) 

 

这是本题的，明显发现最后这一串是多出来的，手动敲出来

FB3EFCE4CEAC2F5445C7AE17E3E969AB，发现并不是密码，但是应该就是它很可疑，进行解码，终于，在md5这找到了密码

![img](/wps13.jpg) 

 

拿到了文件，拖入winhex

![img](/wps14.jpg) 

发现又是张图片，修改后缀，发现不对。想到了一个之前收集的强大工具gimp，将文件后缀名改成data拖进去

![img](/wps15.jpg) 

出了！，可以看清楚flag，左右移动一下，手动敲就出来了

flag{607f41da-e849-4c0b-8867-1b3c74536cc4}

 

 