---
title: 国赛 misc ez_usb
date: 2022-06-019 22:19:11
tags:
- misc
categories:
- [比赛，2022国赛]
---

下载附件，发现是usb的流量分析

![img](/wps1.jpg) 

直接拖进kali中使用keyboard脚本，发现跑不出东西，想到应该需要过滤

尝试尝试，在过滤usb.src =="2.8.1"的时候发现了线索，以该过滤导出压缩包

左上角，导出特定分组

![img](/wps2.jpg) 

 

用usbkeyboard脚本跑

![img](/wps3.jpg) 

 

看到了rar，用winhex打开数据（这里要清除不相关数据后放入）

![img](/wps4.jpg) 

转化成rar压缩包，发现了加密的txt文件，需要寻找密码，一开始没什么头绪，就想着继续过滤一下，没想到在usb.src =="2.10.1"时发现了东西，一样的方法导出另一个流量包并且用脚本跑

（本题所用的keyboard脚本均为github拉下来的）

脚本：

\#!/usr/bin/env python

 

import sys

import os

 

DataFileName = "usb.dat"

 

presses = []

 

normalKeys = {"04":"a", "05":"b", "06":"c", "07":"d", "08":"e", "09":"f", "0a":"g", "0b":"h", "0c":"i", "0d":"j", "0e":"k", "0f":"l", "10":"m", "11":"n", "12":"o", "13":"p", "14":"q", "15":"r", "16":"s", "17":"t", "18":"u", "19":"v", "1a":"w", "1b":"x", "1c":"y", "1d":"z","1e":"1", "1f":"2", "20":"3", "21":"4", "22":"5", "23":"6","24":"7","25":"8","26":"9","27":"0","28":"<RET>","29":"<ESC>","2a":"<DEL>", "2b":"\t","2c":"<SPACE>","2d":"-","2e":"=","2f":"[","30":"]","31":"\\","32":"<NON>","33":";","34":"'","35":"<GA>","36":",","37":".","38":"/","39":"<CAP>","3a":"<F1>","3b":"<F2>", "3c":"<F3>","3d":"<F4>","3e":"<F5>","3f":"<F6>","40":"<F7>","41":"<F8>","42":"<F9>","43":"<F10>","44":"<F11>","45":"<F12>"}

 

shiftKeys = {"04":"A", "05":"B", "06":"C", "07":"D", "08":"E", "09":"F", "0a":"G", "0b":"H", "0c":"I", "0d":"J", "0e":"K", "0f":"L", "10":"M", "11":"N", "12":"O", "13":"P", "14":"Q", "15":"R", "16":"S", "17":"T", "18":"U", "19":"V", "1a":"W", "1b":"X", "1c":"Y", "1d":"Z","1e":"!", "1f":"@", "20":"#", "21":"$", "22":"%", "23":"^","24":"&","25":"*","26":"(","27":")","28":"<RET>","29":"<ESC>","2a":"<DEL>", "2b":"\t","2c":"<SPACE>","2d":"_","2e":"+","2f":"{","30":"}","31":"|","32":"<NON>","33":"\"","34":":","35":"<GA>","36":"<","37":">","38":"?","39":"<CAP>","3a":"<F1>","3b":"<F2>", "3c":"<F3>","3d":"<F4>","3e":"<F5>","3f":"<F6>","40":"<F7>","41":"<F8>","42":"<F9>","43":"<F10>","44":"<F11>","45":"<F12>"}

 

def main():

  \# check argv

  if len(sys.argv) != 2:

​    print("Usage : ")

​    print("     python UsbKeyboardHacker.py data.pcap")

​    print("Tips : ")

​    print("     To use this python script , you must install the tshark first.")

​    print("     You can use `sudo apt-get install tshark` to install it")

​    print("Author : ")

​    print("     WangYihang <wangyihanger@gmail.com>")

​    print("     If you have any questions , please contact me by email.")

​    print("     Thank you for using.")

​    exit(1)

 

  \# get argv

  pcapFilePath = sys.argv[1]

  

  \# get data of pcap

  os.system("tshark -r %s -T fields -e usb.capdata 'usb.data_len == 8' > %s" % (pcapFilePath, DataFileName))

 

  \# read data

  with open(DataFileName, "r") as f:

​    for line in f:

​      presses.append(line[0:-1])

  \# handle

  result = ""

  for press in presses:

​    if press == '':

​      continue

​    if ':' in press:

​      Bytes = press.split(":")

​    else:

​      Bytes = [press[i:i+2] for i in range(0, len(press), 2)]

​    if Bytes[0] == "00":

​      if Bytes[2] != "00" and normalKeys.get(Bytes[2]):

​        result += normalKeys[Bytes[2]]

​    elif int(Bytes[0],16) & 0b10 or int(Bytes[0],16) & 0b100000: # shift key is pressed.

​      if Bytes[2] != "00" and normalKeys.get(Bytes[2]):

​        result += shiftKeys[Bytes[2]]

​    else:

​      print("[-] Unknow Key : %s" % (Bytes[0]))

  print("[+] Found : %s" % (result))

 

  \# clean the temp data

  os.system("rm ./%s" % (DataFileName))

 

 

if __name__ == "__main__":

  main()

 

![img](/wps5.jpg) 

发现了这一串，作为密码，解出！

![img](/wps6.jpg) 

 

 