---
title: 变量1（BUGKU）
date: 2022-07-06 21:12:00
tags:
- web
categories:
- [刷题, web题集]
- [笔记, web笔记]
---

前言：php是一门非常好的语言^o^

打开题目是一段代码：

``` php
<?php  

error_reporting(0);
include "flag1.php";
highlight_file(__file__);
if(isset($_GET['args'])){
    $args = $_GET['args'];
    if(!preg_match("/^\w+$/",$args)){
        die("args error!");
    }
    eval("var_dump($$args);");
}
?>
```

关注到三个点

1、存在eval（**eval类型函数是代码执行**）

2、存在"$$"即存在变量覆盖漏洞（猜测）

3、var_dump()：这个函数可以输出数组（我认为这也可以算一个小小的提示）

4、最后就是要理解这个正则表达式的意思了

/^\w+$/：匹配所有非字母数字，即符号===》将他带入条件中就是输入中不允许存在除数字字母外的东西

一篇文章速成正则：[learn-regex/README-cn.md at master · ziishaned/learn-regex · GitHub](https://github.com/ziishaned/learn-regex/blob/master/translations/README-cn.md#21-点运算符-)

纯字母+$$所以可以使用$GLOBALS 来输出flag

payload：?args=GLOBALS

![image-20220704195653905](/image-20220704195653905.png)

## GET新知识点  php九大全局变量

（借用此题顺便展示一下效果，方便理解）

- $_POST [用于接收post提交的数据]

- $_GET [用于获取url地址栏的参数数据]

  ![image-20220704195403598](/image-20220704195403598.png)

  

- $_FILES [用于文件就收的处理img 最常见]

- $_COOKIE [用于获取与setCookie()中的name 值]

  ![image-20220704195528785](/image-20220704195528785.png)

  

- $_SESSION [用于存储session的值或获取session中的值]

- $_REQUEST [具有get,post的功能，但比较慢]

- SERVER[是预定义服务器变量的一种，所有SERVER[是预定义服务器变量的一种，所有_SERVER [是预定义服务器变量的一种，所有_SERVER开头的都

- $GLOBALS [一个包含了全部变量的全局组合数组]

  ![image-20220704195847966](/image-20220704195847966.png)

  效果如上

- $_ENV [ 是一个包含服务器端环境变量的数组。它是PHP中一个超级全局变量，我们可以在PHP 程序的任何地方直接访问它]



