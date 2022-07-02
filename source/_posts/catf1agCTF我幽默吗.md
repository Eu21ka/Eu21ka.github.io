---
title: (catf1agCTF)我幽默吗?
date: 2022-07-01 22:07:11
tags:
- web
categories:
- [刷题, web题集]
---

进入题目：

发现是空白页面，点击万能的f12发现注释中果然藏了东西

![image-20220701205934697](/image-20220701205934697.png)

仔细观察发现是一个密码本，进行对照翻译

![image-20220701210012170](/image-20220701210012170.png)

发现提示了一个source，在url中传入source=xxxx（任意值进行尝试）获得以下代码：

![image-20220701210259854](/image-20220701210259854.png)

仔细阅读后发现总共要传入三个值a，b，c

之后对flag文件位置进行查询：

payload：a=DirectoryIterator&b=glob://flag[a-z0-9]*.php&c=9223372036854775806

![image-20220701214011951](/image-20220701214011951.png)



获取flag

payload：a=SplFileObject&b=php://filter/convert.base64-encode/resource=flag56ea8b83122449e814e0fd7bfb5f220a.php&c=9223372036854775806

![image-20220701214053812](/image-20220701214053812.png)



解密获得最终结果：

![image-20220701210702783](/image-20220701210702783.png)



## get新知识

当出现类似如下代码时可以利用原生类配合php伪协议使用获取flag

![image-20220701210422844](/image-20220701210422844.png)

###    glob协议

   glob://协议是php5.3.0以后一种**查找匹配的文件路径模式**。（后面可以使用正则表达式匹配）

###   遍历目录类（DirectoryIterator）

​    DirectoryIterator类的`__construct`方法会构造一个迭代器，如果使用echo输出该迭代器，将会返回迭代器的第一项

与之类似的还有FilesystemIterator和GlobIterator（自带glob头在使用时不需要在使用glob协议直接正则即可）在DirectoryIterator被禁用的情况下可以使用；

***所以我们可以将glob协议和DirectoryIterator类配合使用达到查询的效果***



## 读取文件类（SplFileObject）

SplFileObject类为文件提供了一个面向对象接口

在读取过程中不一定会成功所以可以配合filter协议使用；



## 绕过$count[]=1（不理解记住即可）

重点在于$count[] = 1此语句正常赋值的时候返回结果为1

可以通过溢出来跳出此语句的判断

作为PHP最重要的数据类型HashTable其key值是有一定的范围的，如果设置的key值过大就会出现溢出的问题而这个数字就是临界点9223372036854775807



特别鸣谢大佬博客：

[(19条消息) 我幽默吗？_king_Sinner的博客-CSDN博客](https://blog.csdn.net/cng_Sinner/article/details/123345424)

[(19条消息) 记一道2021浙江省赛的Web题_合天网安实验室的博客-CSDN博客](https://blog.csdn.net/qq_38154820/article/details/121112935)

