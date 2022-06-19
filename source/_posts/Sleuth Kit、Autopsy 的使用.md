---
title: Sleuth Kit、Autopsy 的使用
date: 2022-06-019 22:19:11
tags:
- misc
categories:
- [笔记，misc笔记]
---

这是picoctf中涉及到的一个工具，配置的教程网上有，这里记录一下我在过程当中遇到的问题

这是教程网站：

https://linux.cn/article-5541-1.html

因为不懂，所以尽管跟着教程走也走了不少的弯路，这里建议大家跟着教程走，所以Autopsy 的版本最好和教程一样。这是下载Autopsy 2.24源码的网址：

https://sourceforge.net/projects/autopsy/files/autopsy/2.24/

也可以跟着官网去配置最新版本（http://www.sleuthkit.org/sleuthkit/ 这是官网，Autopsy 也可以在里面找到），那个稍微有些麻烦，可能会有不断地报错，但如果对linux命令熟悉且精通的话，那大可以忽略我的话。

这里就说说2.24版本，首先我们需要用root权限保持Autopsy 的后台开启着，不然他就会报错（记住要用root权限）

![img](/wps4.jpg) 

这是报错情况

![img](/wps5.jpg) 

这样就可以了，根据链接打开工具

![img](/wps6.jpg) 

接下来可以New Case 跟着上面的教程走，中间如果出现了没有发现下一步的按钮时，建议试一下重启虚拟机，重新来一遍。在里面你可以选择查看整个磁盘，也可以查看磁盘的一个分区。总之，多用用就行了。在下载的过程中如果遇到了报错，可以根据报错去寻找解决的方案。最重要的是找到自己可以配置成功的版本，启动并使用工具。

 