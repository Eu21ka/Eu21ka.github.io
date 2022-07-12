---
title: embryoio level29~level35
date: 2022-06-22 21:33:11
tags:
- pwn
categories:
- [刷题, pwncollege刷题]
---

# embryoio level29

## 题目简介

主要掌握c语言系统调用的使用



## 解题流程

### 运行程序

![image-20220622191010760](/image-20220622191010760.png)

上面大致意思就是需要我们在用户目录下写个`.c`文件，并编译生成一个二进制文件，这个二进制程序里面需要有一个名叫`pwncollege`的方法，我们需要在父进程运行二进制文件，在子进程里执行题目程序。



### 编写c程序

```c
#include <stdio.h>
#include <unistd.h>

void pwncollege(char* argv[],char *env[]){
 execve("/challenge/embryoio_level29",argv,env);
    return ;
}

int main(int argc,char* argv[],char* env[]){
    pid_t fpid;
    fpid=fork();
    if(fpid<0)
            printf("error in fork!\n");
    else if (fpid==0){
            printf("我是子进程\n");
            pwncollege(argv,env);
    }
    else{
            printf("我是父进程\n");
            wait(NULL);
    }
    return 0;
}

```

以上代码主要实现的是，利用`fork()`创建一个子进程，用`fpid`的值来标识程序目前是在执行哪个进程，如果是子进程，则执行`execve()`系统调用。如果是父进程则等待子进程结束。程序写好后使用以下shell指令编译c文件。

```shell
gcc run.c -o run		#我这里的文件名是“run.c”，“-o”表示自己定义生成的二进制文件文件名，默认是“a.out”。
```

编译成功后`./run`运行后即可获得flag。



# embryoio level30~level35

后面的题目解题方法也是和之前的一样，所以还是老样子就放个exp，不讲太多，需要注意的是，每次修改c文件后都要重新编译。



## EXP

```c
//================level30================
//c程序和level29一样，只不过是运行后还需要输入password（程序会给）

//================level31================
void pwncollege(char* argv[],char *env[]){
    char *newargv[]={"embryoio_level31","password",NULL}; //这题需要一个外部参数作为密码，其它代码不变，将password替换为程序给出的密码
    execve("/challenge/embryoio_level31",newargv,env);
    return ;
}

//================level32================
void pwncollege(char* argv[],char *env[]){
    char *newenv[] = {"environment=value",NULL};	//这题和上一题差不多，替换为对应的环境变量即可
    execve("/challenge/embryoio_level32",argv,newenv); 
    return ;
}

//================level33================
//c程序和level29一样，只不过是需要在执行的时候有个重定向操作
//使用“./run < /tmp/filename”执行（filename替换为程序给出的文件名），会给出需要的密码提示，将密码写进去再次运行则可以拿到flag

//================level34================
//具体操作和上一题差不多
//使用“./run > /tmp/filename”执行，flag就被输出到目标文件下，cat以下即可获得flag。

//================level35================
void pwncollege(char* argv[],char *env[]){
    char *newenv[] = {NULL};		//这题需要一个空环境变量，那么就将newenv设为NULL即可，其它代码保持不变，运行即可获得flag。
    execve("/challenge/embryoio_level35",argv,newenv);
    return ;
}

```



