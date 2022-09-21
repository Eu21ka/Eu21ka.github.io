---
title: 强网青少赛miscWP
date: 2022-09-21 11:36:00
tags:
- misc
categories:
- [比赛]
---

# misc1

下载附件，发现是一张打不开的图片，拖进010看看

![图片](强网青少赛(miscWP)/clip_image002.gif)

发现是base64码，先去在线网站解码看看

![图片](强网青少赛(miscWP)/clip_image004.gif)

发现应该是一张png，但是每两位都被交换了位置，于是用脚本解码并转换16进制

from binascii import *

from base64 import *

 

with open('chuyinweilai.png', 'r') as f:

  hexdata = b64decode(f.read())

  b_data = b''

  for i in range(0, len(hexdata), 2):

   data = hexdata[i:i+2]

   b_data += data[::-1]

  with open('flag.png', 'wb') as f1:

   f1.write(b_data)

得到图片

![图片](强网青少赛(miscWP)/clip_image006.gif)

图片提示密钥就是音乐的财富密码，说明图片具有密钥，上网搜一下

![图片](强网青少赛(miscWP)/clip_image008.gif)

密钥应该就是4536251，outguess和steghide都不是，想起来有个lsb解密也需要密钥，试一试

python2 lsb.py extract flag.png 1.txt 4536251

![图片](强网青少赛(miscWP)/clip_image010.gif)

得到1.txt，打开得到flag

flag{5cc0aa21208b517dbd0bde650247237f}

 

# misc3

下载附件

![图片](强网青少赛(miscWP)/clip_image012.gif)

又是lsb隐写，先拖入010看看

![图片](强网青少赛(miscWP)/clip_image014.gif)发现了一张png和password，先binwalk分离

有密码的图片，还是试试lsb.py

python2 lsb.py extract secret.png 1.txt 7his_1s_p4s5w0rd

![图片](强网青少赛(miscWP)/clip_image016.gif)打开1.txt得到flag，

flag{2e55f884-ef01-4654-87b1-cc3111800085}

 