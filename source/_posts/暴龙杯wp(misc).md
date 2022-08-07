---
title: 暴龙杯wp(misc)
date: 2022-08-07 15:07:00
tags:
- misc
categories:
- [比赛, 2022]
---

签到

下下来一个压缩包，一张png图片，拖到浏览器中发现是apng，用工具分离出来就好

![图片](暴龙杯wp(misc)/clip_image002.gif)

得到flag，BLCTF{Y0u_Kn0w_Apng!!!!!}

 

Ez_zip

打开发现是一个无限套娃的压缩包，直接用脚本跑

from zipfile import *

from os import *

 

init_name = '98895'

name_list = []

path = getcwd()

zip_name = init_name

while True:

  try:

   name_list.append(zip_name)

   file = ZipFile(zip_name+'.zip', 'r')

   if(file):

​     file.extractall(path, pwd=zip_name.encode('utf-8'))

​     zip_name = file.namelist()[0][:-4]

   else:

​     continue

  except:

   break

print(name_list)

跑出来最后一个flag.zip,发现是加密文件，调整长度进行爆破

![图片](暴龙杯wp(misc)/clip_image004.gif)

发现密码是999999，解压出来一个flag.png拖入浏览器发现还是apng，分离

![图片](暴龙杯wp(misc)/clip_image006.gif)

得flag，BLCTF{731b9cdf-6022-4429-8949-b1e4a757db30}

 

嫌疑人X

首先打开压缩包，会发现info文件夹下有个隐藏文件，把隐藏按钮打开就好

![图片](暴龙杯wp(misc)/clip_image008.gif)

发现这个诺基亚.rar和上一级文件夹中pcap.rar都是加密文件

看了看发现只有一张证件照是有相关信息的

![图片](暴龙杯wp(misc)/clip_image010.gif)

根据一般的密码的设置套路，名字+生日，试了好久还是试不出，根据提示知道了诺基亚的密码是Lx1x9x0x0x

立马想到密码是Lw19970608

解开诺基亚.rar

![图片](暴龙杯wp(misc)/clip_image012.gif)

是一张诺基亚的照片，拖进winhex看看

![图片](暴龙杯wp(misc)/clip_image014.gif)

 

发现有个压缩包，foremost分离出来，发现要密码

winhex修改伪加密

![图片](暴龙杯wp(misc)/clip_image016.gif)

打开秘密.txt发现是九键键盘解密

![图片](暴龙杯wp(misc)/clip_image018.gif)

对照着那张诺基亚三个五代表l，四个七代表s，以此类推，出来的结果是

lsjddwyyyyy，这一看就是另一个rar的密码了

wireshark分析pcapng文件

在udp追踪流0的时候发现flag

![图片](暴龙杯wp(misc)/clip_image020.gif)

最终答案是BLCTF{YOU_ARE_A_GREAT_ASSISTANT}

 

BitMask

压缩包直接是加密的，根据注释提示是六位密码

![图片](暴龙杯wp(misc)/clip_image022.gif)

 

直接先六位纯数字爆破

![图片](暴龙杯wp(misc)/clip_image024.gif)

密码是21964

![图片](暴龙杯wp(misc)/clip_image026.gif)

发现了被污染的二维码，用网站手拼二维码进行扫描

https://merricx.github.io/qrazybox/

![图片](暴龙杯wp(misc)/clip_image028.gif)

![图片](暴龙杯wp(misc)/clip_image030.gif)

解出457c，把原图zsteg的时候发现应该里面还有一张图片，但是分离不出来

![图片](暴龙杯wp(misc)/clip_image032.gif)

猜测是有损坏，放入winhex搜索IEND

![图片](暴龙杯wp(misc)/clip_image034.gif)

第一个IEND处发现png的文件头没有补齐，将它分离出来并且用8950补齐头部

![图片](暴龙杯wp(misc)/clip_image036.gif)

保存下来一张新的二维码，发现扫不了，应该是对掩码进行了调整

还是用之前的那个网站对新保存下来的这张二维码进行掩码修复，顺序是076

![图片](暴龙杯wp(misc)/clip_image038.gif)

扫出来的结果是前半截的flag，在原图binwalk的时候发现1675这个文件用记事本打开的时候是一串编码

![图片](暴龙杯wp(misc)/clip_image040.gif)

![图片](暴龙杯wp(misc)/clip_image042.gif)

对编码进行解码，将该二进制从头部一位一位剔除进行二进制转换

![图片](暴龙杯wp(misc)/clip_image044.gif)

 

得到flag后半部分，拼接起来BLCTF{675af7c9-fb5b-xxxx-9fde-415a5253db08}

想到之前有个手拼扫描出来的四位数457c，应该就是这四个xxxx了，拼接起来得flag

BLCTF{675af7c9-fb5b-457c-9fde-415a5253db08}