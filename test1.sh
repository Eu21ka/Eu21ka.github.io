"my_script.sh" 0L, 0C
/challenge/embryoio_level8
PowerShell 7.2.4
Copyright (c) Microsoft Corporation.

https://aka.ms/powershell
Type 'help' to get help.

PS C:\Users\16956\Desktop> ssh hacker@dojo.pwn.college
Connected!
hacker@embryoio_level8:~$ cd /challenge/
hacker@embryoio_level8:/challenge$ ls
checker.py  embryoio_level8
hacker@embryoio_level8:/challenge$ ./embryoio_level8
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level8:/challenge$ ls
checker.py  embryoio_level8
hacker@embryoio_level8:/challenge$ touch my_script.sh
touch: cannot touch 'my_script.sh': Permission denied
hacker@embryoio_level8:/challenge$ cd
hacker@embryoio_level8:~$ touch my_script.sh
hacker@embryoio_level8:~$ ls
my_script.sh

/challenge/embryoio_level9
hacker@embryoio_level8:~$ vim my_script.sh
hacker@embryoio_level8:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:
pwn.college{AlTMs5zZE1KNdldCXOfWB_BI8J1.0FOskjNxQzW}

hacker@embryoio_level8:~$
Connected!
hacker@embryoio_level9:~$ cd /challenge/
hacker@embryoio_level9:/challenge$ ls
checker.py  embryoio_level9
hacker@embryoio_level9:/challenge$ ./embryoio_level9
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level9:/challenge$ ls






























"my_script.sh" 1L, 27C
/challenge/embryoio_level10
checker.py  embryoio_level9
hacker@embryoio_level9:/challenge$ cd
hacker@embryoio_level9:~$ ls
my_script.sh
hacker@embryoio_level9:~$ vim my_script.sh
hacker@embryoio_level9:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] This program expects you to enter a simple password (specifically, rlcvktck). Send it now!
[INFO] Reading in your input now...
rlcvktck
[GOOD] You successfully passed the password!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:






























"my_script.sh" 1L, 28C
/challenge/embryoio_level10 lswcraneju
pwn.college{4vkqGwjBIFvjsXWDURyJNEjXvCR.0VOskjNxQzW}

hacker@embryoio_level9:~$
Connected!
hacker@embryoio_level10:~$ /challenge/embryoio_level10
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level10:~$ vim my_script.sh
hacker@embryoio_level10:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] My argv[1] should have a value of lswcraneju! Let's check...
Traceback (most recent call last):
  File "/challenge/checker.py", line 492, in <module>

/challenge/embryoio_level11
    do_checks(_args)
  File "/challenge/checker.py", line 376, in do_checks
    check_arg(args.old_args[1:], n, v)
  File "/challenge/checker.py", line 223, in check_arg
    assert args[n] == v, f"argv[{n}] is not '{v}' (it seems to be '{args[n]}', instead)."
IndexError: list index out of range
hacker@embryoio_level10:~$ vim my_script.sh
hacker@embryoio_level10:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.

env -i ugdygr=ybezdhyzoq /challenge/embryoio_level11
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] My argv[1] should have a value of lswcraneju! Let's check...
[GOOD] You successfully passed the argument value check!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:
pwn.college{4IKPvF9hYVaXgxREuLnOyE4Ewmn.dBTMskjNxQzW}

hacker@embryoio_level10:~$
Connected!
hacker@embryoio_level11:~$ /challenge/embryoio_level11
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level11:~$ vim my_script.sh
hacker@embryoio_level11:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.

#env -i ugdygr=ybezdhyzoq
[TEST] Checking to make sure the process is a non-interactive shell script.






























"my_script.sh" 2L, 54C
#env -i ugdygr=ybezdhyzoq
[GOOD] You have passed the checks on the parent process!
[TEST] My 'ugdygr' environment variable should have a value of ybezdhyzoq! Let's check...
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    Your environment does not have a variable ugdygr.
hacker@embryoio_level11:~$ vim my_script.sh
hacker@embryoio_level11:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] My 'ugdygr' environment variable should have a value of ybezdhyzoq! Let's check...
[GOOD] You successfully passed the environment value check!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:
pwn.college{w1lpQm9BmBKOvjrvlc8DXgxSIEZ.dFTMskjNxQzW}


FD_CLOEXEC
hacker@embryoio_level11:~$






























"my_script.sh" 2L, 54C
#env -i ugdygr=ybezdhyzoq
Connected!

#env -i ugdygr=ybezdhyzoq
hacker@embryoio_level12:~$ /challenge/embryoio_level12
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level12:~$ vim my_script.sh
hacker@embryoio_level12:~$ vim my_script.sh
hacker@embryoio_level12:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should have redirected a file called /tmp/vkkrve to my stdin. Checking...
[TEST] I will now check that you redirected /tmp/vkkrve to/from my stdin.

[ADVICE] File descriptors are inherited from the parent, unless the FD_CLOEXEC is set by the parent on the file descript
#env -i ugdygr=ybezdhyzoq
or.

tflbbkaw
[ADVICE] For security reasons, some programs, such as python, do this by default in certain cases. Be careful if you are
[ADVICE] creating and trying to pass in FDs in python.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    You have not redirected anything for this process' stdin.
hacker@embryoio_level12:~$ vim /tmp/vkkrve
hacker@embryoio_level12:~$ vim my_script.sh
hacker@embryoio_level12:~$ vim my_script.sh
hacker@embryoio_level12:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should have redirected a file called /tmp/vkkrve to my stdin. Checking...
[TEST] I will now check that you redirected /tmp/vkkrve to/from my stdin.

[ADVICE] File descriptors are inherited from the parent, unless the FD_CLOEXEC is set by the parent on the file descriptor.
[ADVICE] For security reasons, some programs, such as python, do this by default in certain cases. Be careful if you are
[ADVICE] creating and trying to pass in FDs in python.
[GOOD] The file at the other end of my stdin looks okay!
[TEST] This program expects you to enter a simple password (specifically, tflbbkaw). Send it now!
[INFO] Reading in your input now...
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    You entered the wrong password (FD_CLOEXEC instead of tflbbkaw).
hacker@embryoio_level12:~$ vim my_script.sh
hacker@embryoio_level12:~$ vim /tmp/vkkrve
hacker@embryoio_level12:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.






























"my_script.sh" 2L, 68C
#env -i ugdygr=ybezdhyzoq
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should have redirected a file called /tmp/vkkrve to my stdin. Checking...
[TEST] I will now check that you redirected /tmp/vkkrve to/from my stdin.

[ADVICE] File descriptors are inherited from the parent, unless the FD_CLOEXEC is set by the parent on the file descriptor.
[ADVICE] For security reasons, some programs, such as python, do this by default in certain cases. Be careful if you are
[ADVICE] creating and trying to pass in FDs in python.
[GOOD] The file at the other end of my stdin looks okay!
[TEST] This program expects you to enter a simple password (specifically, tflbbkaw). Send it now!
[INFO] Reading in your input now...
[GOOD] You successfully passed the password!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:
pwn.college{k2skXRiOhPScCD2T0JpW35Lg2Ku.dJTMskjNxQzW}

hacker@embryoio_level12:~$
Connected!
hacker@embryoio_level13:~$ /challenge/embryoio_level13
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.


[FAIL] You did not satisfy all the execution requirements.

#env -i ugdygr=ybezdhyzoq
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level13:~$ vim my_script.sh
hacker@embryoio_level13:~$ /challenge/embryoio_level13
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level13:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should have redirected my stdout to a file called /tmp/lxhgyi. Checking...
[TEST] I will now check that you redirected /tmp/lxhgyi to/from my stdout.

[ADVICE] File descriptors are inherited from the parent, unless the FD_CLOEXEC is set by the parent on the file descriptor.
[ADVICE] For security reasons, some programs, such as python, do this by default in certain cases. Be careful if you are
[ADVICE] creating and trying to pass in FDs in python.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    You have not redirected anything for this process' stdout.
hacker@embryoio_level13:~$ vim /tmp/lxhgyi
hacker@embryoio_level13:~$ vim my_script.sh
hacker@embryoio_level13:~$ bash my_script.sh
hacker@embryoio_level13:~$ cat /tmp/lxhgyi
[INFO] This challenge will now perform a bunch of checks.

#env -i ugdygr=ybezdhyzoq
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should have redirected my stdout to a file called /tmp/lxhgyi. Checking...
[TEST] I will now check that you redirected /tmp/lxhgyi to/from my stdout.

[ADVICE] File descriptors are inherited from the parent, unless the FD_CLOEXEC is set by the parent on the file descriptor.
[ADVICE] For security reasons, some programs, such as python, do this by default in certain cases. Be careful if you are
[ADVICE] creating and trying to pass in FDs in python.

#env -i ugdygr=ybezdhyzoq
[GOOD] The file at the other end of my stdout looks okay!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:
pwn.college{QlzUY2wrMe4FmH8H1FwuB0xXA7H.dNTMskjNxQzW}






























"my_script.sh" 2L, 61C
#env -i ugdygr=ybezdhyzoq

hacker@embryoio_level13:~$
hacker@embryoio_level13:~$
Connected!
hacker@embryoio_level13:~$
Connected!
hacker@embryoio_level14:~$ /challenge/embryoio_level14
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    The shell process must be executing a shell script that you wrote like this: `bash my_script.sh`
hacker@embryoio_level14:~$ vim my_script.sh
hacker@embryoio_level14:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should launch me with an empty environment. Checking...
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    You should launch this program with 0 environment variables, but you have 16!
hacker@embryoio_level14:~$ vim my_script.sh
hacker@embryoio_level14:~$ bash my_script.sh
my_script.sh: line 2: evn: command not found
hacker@embryoio_level14:~$ vim my_script.sh
hacker@embryoio_level14:~$ bash my_script.sh
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] Checking to make sure the process is a non-interactive shell script.
[GOOD] You have passed the checks on the parent process!
[TEST] You should launch me with an empty environment. Checking...
[GOOD] You successfully passed the empty environment check!
[GOOD] Success! You have satisfied all execution requirements. Here is your flag:
pwn.college{IPcxX9CIImZvnvk8oJ5tmqBNdMK.dRTMskjNxQzW}

hacker@embryoio_level14:~$
Connected!
hacker@embryoio_level15:~$ /challenge/embryoio_level15
[INFO] This challenge will now perform a bunch of checks.
[INFO] If you pass these checks, you will receive the flag.
[TEST] Performing checks on the parent process of this process.
[TEST] We will now check that that the process is an interactive ipython instance.

[INFO] Since ipython runs as a script inside python, this will check a few things:
[INFO] 1. That the process itself is python.
[INFO] 2. That the module being run in python is ipython.
[INFO] If the process being checked is just a normal 'ipython', you'll be okay!

[INFO] The process' executable is /usr/bin/bash.
[INFO] This might be different than expected because of symbolic links (for example, from /usr/bin/python to /usr/bin/python3 to /usr/bin/python3.8).
[INFO] To pass the checks, the executable must be python3.8.
[FAIL] You did not satisfy all the execution requirements.
[FAIL] Specifically, you must fix the following issue:
[FAIL]    Executable must be 'python'. Yours is: bash
hacker@embryoio_level15:~$ cd /ha
bash: cd: /ha: No such file or directory
hacker@embryoio_level15:~$ cd /challenge/
hacker@embryoio_level15:/challenge$ ls
checker.py  embryoio_level15
hacker@embryoio_level15:/challenge$
Connected!
hacker@embryoio_level4:~$