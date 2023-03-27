---
title: java类加载器
date: 2023-03-27 20:05:00
tags:
- web
categories:
- [web笔记]
---

# java基础学习

### 运行机制

java程序的运行是一个有意思的过程

![image-20230318171149207](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318171149207.png)

编译过程实在JVM（java虚拟机）中完成的我们在IDE中编写的Java源代码被编译器编译成**.class**的字节码文件。然后由我们得ClassLoader负责将这些class文件给加载到JVM中去执行；这里使用一张完整的图片

![image-20230318171402189](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318171402189.png)



### 类加载器（ClassLoader）

#### 概念

Java类加载器(Java Classloader)是Java运行时环境(Java Runtime Environment)的一部分，负责动态加载Java类到Java虚拟机的内存空间中，用于加载系统、网络或者其他来源的类文件。Java源代码通过javac编译器编译成类文件，然后JVM来执行类文件中的字节码来执行程序。



#### 类加载器的分类

类加载器大致分为两种，一种是JVM自带的类加载器，另一种则是用户自定义的类加载器；其中JVM自带的类加载器又分别为引导类加载器、扩展类加载器和系统类加载器。另外一种就是用户自定义的类加载器，可以通过继承java.lang.ClassLoader类的方式实现自己的类加载器。



### JVM自带的类加载器

##### 引导类加载器

引导类加载器(BootstrapClassLoader)，底层原生代码是C++语言编写，属于jvm一部分，**不继承java.lang.ClassLoader类**，也没有父加载器，主要负责加载核心java库(即JVM本身)，存储在/jre/lib/rt.jar目录当中。(同时处于安全考虑，BootstrapClassLoader只加载包名为java、javax、sun等开头的类)。

这里以jdk1.8为例，这里我们看到/jre/lib/rt.jar目录，这里面的类都是由BootstrapClassLoader来加载。

![image-20230318163432328](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318163432328.png)

Object类是java中的一个特殊类，也是所有类的父类，也就是说，Java 允许把任何类型的对象赋给 Object 类型的变量。当一个类被定义后，如果没有指定继承的父类，那么默认父类就是 Object 类；我们这里以object为测试看一看其是否存在父加载器

![image-20230318163858272](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318163858272.png)

我们可以看出object的父类加载器为null；



##### 扩展类加载器

扩展类加载器(ExtensionsClassLoader)，由sun.misc.Launcher$ExtClassLoader类实现，用来在/jre/lib/ext或者java.ext.dirs中指明的目录加载java的扩展库。Java虚拟机会提供一个扩展库目录，此加载器在目录里面查找并加载java类。

根据描述在`C:\Program Files\Java\jre1.8.0_331\lib\ext`目录下的jar包都是由ExtensionsClassLoader进行加载

![image-20230318164901711](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318164901711.png)

我们随机选一个上图中的jar包然后产看其中类加载器（此处以sunec.SunEC为例）

![image-20230318165420568](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318165420568.png)

我们可以看到其类加载器为ExtensionsClassLoader；

##### App类记载器/系统类加载器（AppClassLoader）

App类加载器/系统类加载器（AppClassLoader），由sun.misc.Launcher$AppClassLoader实现，一般通过通过(java.class.path或者Classpath环境变量)来加载Java类，也就是我们常说的classpath路径。通常我们是使用这个加载类来加载Java应用类，可以使用ClassLoader.getSystemClassLoader()来获取它。

这里我们使用本身写的ClassLoaderTest类进行测试，发现存在于AppClassLoader。

![image-20230318165839723](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318165839723.png)



##### 双亲委派机制

它们之间的层次关系被称为类加载器的双亲委派模型

![image-20230318173021571](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230318173021571.png)

双亲委派模型的工作过程为：如果一个类加载器收到了类加载的请求，它首先不会自己去尝试加载这个类，而是把这个请求委派给父类加载器去完成，每一个层次的加载器都是如此，因此所有的类加载请求都会传给顶层的启动类加载器，只有当父加载器反馈自己无法完成该加载请求（该加载器的搜索范围中没有找到对应的类）时，子加载器才会尝试自己去加载。（言简意赅的说就是先找爹，爹不行再靠自己，找父类的顺序如上图所示）



##### 双亲委派机制的好处

1、避免重复加载

2、保证java核心库的类型安全 ；例如我们上传一个Object类，因为双亲委派机制的存在通过父类的识别，子类中的Object类将不会被加载，保证我们的java核心API库不被篡改；

![image-20230319172417359](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230319172417359.png)



### 自定义类加载器

在进入自定义类加载器之前我们先看一下ClassLoaer类中的核心方法

#### ClassLoader类的核心方法

##### loadclasss(加载指定的java类)

```java
protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
{
    synchronized (getClassLoadingLock(name)) {
        // First, check if the class has already been loaded
        Class<?> c = findLoadedClass(name);
        if (c == null) {
            long t0 = System.nanoTime();
            try {
                if (parent != null) {
                    c = parent.loadClass(name, false); 
                } else {
                    c = findBootstrapClassOrNull(name);
                }
            } catch (ClassNotFoundException e) {
                // ClassNotFoundException thrown if class not found
                // from the non-null parent class loader
            }

            if (c == null) { 
                // If still not found, then invoke findClass in order
                // to find the class.
                long t1 = System.nanoTime();
                c = findClass(name);

                // this is the defining class loader; record the stats
                sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                sun.misc.PerfCounter.getFindClasses().increment();
            }
        }
        if (resolve) {
            resolveClass(c);
        }
        return c;
    }
}
```



##### findclass(查找指定的Java类)

```java
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        throw new ClassNotFoundException(name);
    }
```



##### findLoadedClass(查找JVM已经加载过的类)

```java
    protected final Class<?> findLoadedClass(String name) {
        if (!checkName(name))
            return null;
        return findLoadedClass0(name);
    }
```



##### defineClass

```java
    protected final Class<?> defineClass(byte[] b, int off, int len)
        throws ClassFormatError
    {
        return defineClass(null, b, off, len, null);
    }
```



##### resolveClass

```java
protected final void resolveClass(Class<?> c) {
        resolveClass0(c);
    }
```



#### 自定义类加载器

在实际应用过程中，我们不仅仅只希望使用classpath当中指定的类或者jar包进行调用使用，我们有时希望调用本地磁盘文件或者网络还可以使用自定义类加载器的方式

自定义类加载器步骤：

- 继承classloader类
- 覆盖findclass()方法
- 在findClass()方法中调用defineClass()方法

##### URLClassLoader

URLClassLoader类继承ClassLoader类，可以加载本地磁盘和网络中的jar包类文件。

我们在创建了一个Main.java文件，写了一段calc.exe计算机弹窗代码。如果文件被成功解析执行，会输出Test calc success！！！字段且弹出计算器。

```java
package org.example;

public class Main {
    public Main(){
        System.out.println("Test calc success!!!");
        try{
            Runtime.getRuntime().exec("cmd /c calc.exe");
        }
        catch(Exception e) {
            e.printStackTrace();
        }
    }
}
```

我们利用javac编译生成对应的.class文件

![image-20230319235739048](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230319235739048.png)

```java
package org.ClassLoader;

import java.io.File;
import java.net.URI;
import java.net.URL;
import java.net.URLClassLoader;

public class ClassLoaderTest {
    public static void main(String[] args) throws Exception{
        File file = new File("D:\\Javaeeworkspce\\javasecurity\\src\\main\\java\\org\\example");
        URI uri = file.toURI();
        URL url = uri.toURL();

        URLClassLoader classLoader = new URLClassLoader(new URL[]{url});
        Class clazz = classLoader.loadClass("org.example.Main");
        clazz.newInstance();
    }
}

```

我们可以看出成功的弹出了计算器

![image-20230320000050159](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230320000050159.png)

##### 网络传输class文件调用

我们将Test.class放置到电脑的Tomcat服务器目录下(tomcat/webapps/),然后新建个ClassLoaderTest类网络加载Tomcat服务器中的Main.class

```JAVA
package org.ClassLoader;

import java.net.URL;
import java.net.URLClassLoader;

public class ClassLoaderTest {
    public static void main(String[] args) throws Exception{
        URL url = new URL("http://127.0.0.1:8080/examples/");
        URLClassLoader classLoader = new URLClassLoader(new URL[]{url});
        Class clazz = classLoader.loadClass("org.example.Main");
        clazz.newInstance();
    }
}
```

Main.java中还有一段输出Test calc success!!!这里截图失误了

![image-20230320001511079](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230320001511079.png)



参考文章：

[java中双亲委派机制(+总结） - luwanglin - 博客园 (cnblogs.com)](https://www.cnblogs.com/luckforefforts/p/13642685.html)

[JAVA安全基础（一）--类加载器（ClassLoader） - 先知社区 (aliyun.com)](https://xz.aliyun.com/t/9002#toc-9)



