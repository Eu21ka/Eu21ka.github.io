---
title: fd
date: 2022-07-12 19:41:00
tags:
- pwn
categories:
- [刷题, pwnable刷题]
---

## 题目简介

关于read函数的一道程序题



## 保护措施

![屏幕截图 2022-05-09 212129](/屏幕截图 2022-05-09 212129.png)

远程服务器好像不给我们访问flag的权限



## 源码分析

`fd.c`的源码如下

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char buf[32];
int main(int argc, char* argv[], char* envp[]){
        if(argc<2){
                printf("pass argv[1] a number\n");		//参数必须大于2
                return 0;
        }
        int fd = atoi( argv[1] ) - 0x1234;				//fd的值等于程序运行带传的参数与0x1234的差
        int len = 0;
        len = read(fd, buf, 32);
        if(!strcmp("LETMEWIN\n", buf)){					//strcmp将“LETMEWIN\n”与buf比较
                printf("good job :)\n");
                system("/bin/cat flag");				//打印输出flag
                exit(0);
        }
        printf("learn about Linux file IO\n");
        return 0;

}
```

tips：关于`argv[]`是一个外部参数，这个参数需要我们在运行程序时就顺带传进去，一般`agrv[0] = ./<程序名>` ，`agrv[1]`开始就是我们后续带的值。

**思路：既然`fd`等于外部参数与`0x1234`的差，所以`fd`这个参数对我们来说是可控的，既然`fd`可控，`read`函数就可控，我们可以让`fd`等于0，这样`read`函数就是从输入流里取32字节写到`buf`中，这样我们就可以键盘输入“LETMEWIN”，让程序执行`system系统调用`**



## 程序利用流程

- `./fd 4660`运行程序
- 键盘输入对应字符串
- 得到flag



## 解法

```shell
$./fd 4660	#回车
LETMEWIN	#回车
```



![屏幕截图 2022-05-09 214126](/屏幕截图 2022-05-09 214126.png)
