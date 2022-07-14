---
title: PHP特性(web89~web97)
date: 2022-07-14 20:18:00
tags:
- web
categories:
- [刷题, ctfshow刷题]
- [笔记, web笔记]
---

## web 89

``` php
include("flag.php");
highlight_file(__FILE__);

if(isset($_GET['num'])){
    $num = $_GET['num'];
    if(preg_match("/[0-9]/", $num)){
        die("no no no!");
    }
    if(intval($num)){
        echo $flag;
    }
}
```

阅读代码发现满足条件的要求是自相矛盾的，$num既要是数字又不能是数字，所以此处我们使用**数组绕过**

payload：?num[]=1

## web 90

``` php
include("flag.php");
highlight_file(__FILE__);
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if($num==="4476"){
        die("no no no!");
    }
    if(intval($num,0)===4476){
        echo $flag;
    }else{
        echo intval($num,0);
    }
} 
```

**知识点：弱类型（==）与强类型（===）比较**

**1、弱类型（==）**：值相等，故在此比较过程中会出现问题；

eg：若将‘0e’和0进行比较返回值为true原因是在比较时php将（字符串）0e转换为了（int）0在与0进行比较，故返回值为true；



**2、强类型（===）**：值与类型均相等返回为真；

eg：‘0’===0   返回值为false，因为类型不已；



payload：?num=4476e



## web 91(%0a截断)

相关链接：https://blog.csdn.net/weixin_45551083/article/details/110494387

考察PHP模式修饰符m (PCRE_MULTILINE)
默认情况下，PCRE 认为目标字符串是由单行字符组成的(然而实际上它可能会包含多行)， "行首"元字符 (^) 仅匹配字符串的开始位置， 而"行末"元字符 ($) 仅匹配字符串末尾，或者最后的换行符(除非设置了 D 修饰符)。

当这个修饰符设置之后，"行首"和"行末"就会匹配目标字符串中任意换行符之前或之后

当目标字符串中有换行符或者匹配中出现^或者$会受到影响

``` php
show_source(__FILE__);
include('flag.php');
$a=$_GET['cmd'];
if(preg_match('/^php$/im', $a)){
    if(preg_match('/^php$/i', $a)){
        echo 'hacker';
    }
    else{
        echo $flag;
    }
}
else{
    echo 'nonononono';
} 
```

payload:1%0aphp

## web 92

``` php
include("flag.php");
highlight_file(__FILE__);
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if($num==4476){
        die("no no no!");
    }
    if(intval($num,0)==4476){
        echo $flag;
    }else{
        echo intval($num,0);
    }
}
```

**知识点**

**intval()函数：如果$base为0则$var中存在字母的话遇到字母就停止读取**

![image-20220713153459536](/image-20220713153459536.png)



***payload1***：?num=4476e123

在php中有着科学计数的作用所以在进行弱类型比较时不会发生类型转换而是进行了计算，之后又因为intval()函数的特性获取flag

进制绕过：

***payload2***：?num=0x117c



## web 93（进制绕过）

```php
include("flag.php");
highlight_file(__FILE__);
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if($num==4476){
        die("no no no!");
    }
    if(preg_match("/[a-z]/i", $num)){//检测num中是否存在字母
        die("no no no!");
    }
    if(intval($num,0)==4476){
        echo $flag;
    }else{
        echo intval($num,0);
    }
}
```

以0开头将以八进制读取

paylaod:?num=010574



## web 94

``` php
include("flag.php");
highlight_file(__FILE__);
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if($num==="4476"){
        die("no no no!");
    }
    if(preg_match("/[a-z]/i", $num)){
        die("no no no!");
    }
    if(!strpos($num, "0")){
        die("no no no!");
    }
    if(intval($num,0)===4476){
        echo $flag;
    }
} 
```

在web93的基础上禁用了以0开头的数据，但是由于使用===所以我们输入小数，通过类型不一绕过，在使用intval将其转换为int型；

payload：?num=4476.0

payload：?num=%20010574

payload：?num=%2b010574

## web 95

```php
include("flag.php");
highlight_file(__FILE__);
if(isset($_GET['num'])){
    $num = $_GET['num'];
    if($num==4476){
        die("no no no!");
    }
    if(preg_match("/[a-z]|\./i", $num)){
        die("no no no!!");
    }
    if(!strpos($num, "0")){
        die("no no no!!!");
    }
    if(intval($num,0)===4476){
        echo $flag;
    }
}
```

**知识点**

strpos() :函数查找字符串在另一字符串中第一次出现的位置。

故此题strpos()返回不为0即可，所以可以用空格（%20）和加号（%2b）进行干扰

payload：?num=%20010574

payload：?num=%2b010574

## web 96

``` php
highlight_file(__FILE__);

if(isset($_GET['u'])){
    if($_GET['u']=='flag.php'){
        die("no no no");
    }else{
        highlight_file($_GET['u']);
    }
}
```

一开始以为考点是通配符所以经过了*，？的一番尝试之后发现不对一直报错

![image-20220713160253070](/image-20220713160253070.png)

仔细观察报错路径，凭借极少且不风骚的经验猜测是linux下，所以一般flag存放在根目录下经过尝试获得flag

payload：?u=./flag

一些其他的payload：

?u=/var/www/html/flag.php 

?u=php://filter/resource=flag.php

对伪协议的理解不透彻只有在使用file_get_content()时候才想的起来使用，所以 卡了很久；

## web 97 (md5绕过)

相关文章：[(19条消息) 总结ctf中 MD5 绕过的一些思路_yจุ๊บng的博客-CSDN博客_ctf md5绕过](https://blog.csdn.net/CSDNiamcoming/article/details/108837347)

``` php
include("flag.php");
highlight_file(__FILE__);
if (isset($_POST['a']) and isset($_POST['b'])) {
if ($_POST['a'] != $_POST['b'])
if (md5($_POST['a']) === md5($_POST['b']))
echo $flag;
else
print 'Wrong.';
}
?> 
```

此题我使用的是数组绕过，MD5碰撞也可以绕过有兴趣的小伙伴们也可以试一试;

payload:a[]=1&b[]=2 

注意此图需要使用post传值





