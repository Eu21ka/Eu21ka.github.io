---
title: Ubuntu下pwn环境搭建
date: 2023-05-3 21:25:00
tags:
- pwn
categories:
- [笔记, pwn笔记]
---

# 安装Ubuntu虚拟机

## 镜像下载

首先去阿里镜像站或者其它的镜像站将ubuntu的安装镜像下载到本地

[阿里ubuntu镜像地址](https://mirrors.aliyun.com/ubuntu-releases/)

版本推荐16.0以上，我这里使用的是22.04



## 安装VMware

去VMware的官网，下载workstation 16 pro，选择“for windows”。

[官网地址]([Download VMware Workstation Pro](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html))

安装步骤没什么好说的，保持默认总不会错，不会的可以百度亿下。



## 创建新的虚拟机

安装好后打开“VMware Workstation Pro”，点击创建新的虚拟机。

具体方法不多赘述，这里我随便找了一篇可以参考一下。

[创建新的虚拟机](https://blog.csdn.net/Wang_Dou_Dou_/article/details/120107987)



# 配置基本pwn环境

## 更换软件源

为了使我们后续安装软件的时候会顺一些，先换一下软件源，可以选择清华的源。

[ubuntu | 清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)

先将`/etc/apt/source.list` 文件备份一下，然后将里面清空，将下面的地址复制进去。最后执行指令`sudo apt update`更新一下。

```toml
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-proposed main restricted universe multiverse
```



## python和pip安装

因为我们写攻击脚本要用到python，所以我们要把python和pip工具装一下。首先使用一下指令查看下自己虚拟机上有没有安装系统的时候就装好的。

```shell
python
python3
```



我这里表示已经有了python3，下面就只演示python2的安装方式。

![image-20220614131818990](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614131818990.png)



使用指令`sudo apt install python2`安装，安装好后使用指令`python2`检查一下，如下图所示则表示成功。

![image-20220614135641925](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614135641925.png)



使用指令`sudo apt install python3-pip`安装pip3，如下图所示则表示安装成功。

![image-20220614140242893](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614140242893.png)



然后更换pip源，这里我使用的还是清华的源。[pypi |清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/)

使用指令`pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple`



## pwntools安装

使用指令`sudo pip3 install --upgrade pwntools`，因为python2下的pwntools已经不更新了，所以这里用的是python3版本。

输入指令`python3`进入python指令环境，输入以下指令

```python
>>> import pwn
>>> pwn.asm('xor eax,eax')
```



如下图所示，则安装成功。

![image-20220614151050173](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614151050173.png)



## git安装

git是用来帮我们从github来拉取资源的工具，使用指令`sudo apt install git`安装，如下图所示表示成功。

![image-20220614151356542](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614151356542.png)



## pwndbg安装

先在Public目录下使用指令`mkdir tools`新建个文件夹，然后`cd tools`进入该目录，在`tools`目录下使用如下指令

```shell
git clone https://github.com/pwndbg/pwndbg	#从github上克隆
cd pwndbg	#进入克隆下来的包
./setup.sh	#执行安装脚本
gdb	#启动pwndbg测试
```



效果如下则表示成功，到目前为止该环境已经可以拿来做基本的栈溢出题目了。

![image-20220614152045034](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614152045034.png)



# 配置pwn做题辅助工具

## LibcSearcher安装

这是一个师傅自己写的libc查找脚本，我们安装一下，方便以后找libc偏移，在tools目录下使用如下指令安装。

```shell
git clone https://github.com/lieanu/LibcSearcher.git
cd LibcSearcher
sudo python3 setup.py develop
```



效果如下所示则表示成功。

![image-20220614153531126](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614153531126.png)



## one_gadget安装

使用指令`sudo gem install one_gadget`安装，如果提示找不到命令`gem`，则先使用指令`sudo apt install ruby-rubygems`，如下图所示表示成功。

> 20.04及以下版本的ubuntu可能找不到`ruby-rubygems`软件包，就下载`rubygems`这个软件包

![image-20220614162844142](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614162844142.png)



## seccomp-tools安装

使用如下指令

```shell
sudo apt install gcc ruby-dev
sudo gem install seccomp-tools
```

如下图所示则表示成功

![image-20220614163016169](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614163016169.png)



## ROPgadget安装

在`tools`目录下使用以下指令

```shell
git clone https://github.com/JonathanSalwan/ROPgadget.git
cd ROPgadget
sudo python3 setup.py install
```



效果如下则表示成功

![image-20220614165958460](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614165958460.png)



>如果出现如下错误，则使用指令 `sudo cp -r scripts /home/eureka/.local/lib/python3.6/site-packages/ROPGadget-7.1.dist-info` 将ROPgadget下的script复制到它所说的目录下去
>
>![image-20220915145531048](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220915145531048.png)



## glibc-all-in-one安装

在`tools`目录下使用如下指令

```shell
sudo apt install patchelf
git clone https://github.com/matrix1001/glibc-all-in-one.git
cd glibc-all-in-one
python3 update_list
```



效果如下则表示成功

![image-20220614170558948](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20220614170558948.png)







