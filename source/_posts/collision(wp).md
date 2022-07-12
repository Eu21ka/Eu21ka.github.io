---
title: collision
date: 2022-07-12 19:43:00
tags:
- pwn
categories:
- [刷题, pwnable刷题]
---

# 题目简介

一个简单的加密函数逆向的题目



# 解题流程

## 源码分析

```c
#include <stdio.h>
#include <string.h>
unsigned long hashcode = 0x21DD09EC;
unsigned long check_password(const char* p){
        int* ip = (int*)p;		//一个int型占4字节，所以类型转换后20字节的字符被分成了5个int型数字
        int i;
        int res=0;
        for(i=0; i<5; i++){
                res += ip[i];	//刚好循环5次，将5个数字累加起来
        }
        return res;		
}

int main(int argc, char* argv[]){
        if(argc<2){		//运行程序时需要传入一个外部参数
                printf("usage : %s [passcode]\n", argv[0]);	
                return 0;
        }
        if(strlen(argv[1]) != 20){		//该外部参数长度必须等于20字节
                printf("passcode length should be 20 bytes\n");
                return 0;
        }

        if(hashcode == check_password( argv[1] )){		//如果外部参数的值等于hashcode则打印flag
                system("/bin/cat flag");
                return 0;
        }
        else
                printf("wrong passcode.\n");
        return 0;
}
```

通过分析上诉代码可以知道我们只要输入5个数字，并控制他们的和等于`0x21DD09EC`即可。



### 利用

因为`0x21DD09EC`不能被5整除，所以加一整除后再从某个数据中减一即可。

所以我们要输入的5个数字的值为：**0x6C5CEC9、0x6C5CEC9、0x6C5CEC9、0x6C5CEC9、0x6C5CEC8**

这里我们需要将16进制数转码为字符，4字节一组，表示一个16进制数，注意是小端序，所以要逆序写：

**\xc9\xce\xc5\x06\xc9\xce\xc5\x06\xc9\xce\xc5\x06\xc9\xce\xc5\x06\xc8\xce\xc5\x06**

最后借助python将这些字符作为参数传进去。



# shell指令

```shell
./col `python -c 'print "\xc9\xce\xc5\x06\xc9\xce\xc5\x06\xc9\xce\xc5\x06\xc9\xce\xc5\x06\xc8\xce\xc5\x06
"'`
```

