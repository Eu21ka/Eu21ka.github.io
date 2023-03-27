---
title: java反射机制
date: 2023-03-27 20:06:00
tags:
- web
categories:
- [web笔记]
---

# java反射机制

**tips:学习过程中一定要注意一个关键词动态，这是其存在的重要原因，即通过反射我们可以将java这种静态语言附加上动态特性**

### 引

之前再看类加载器的时候直接从概念入手实在是看的云里雾里的以至于整篇笔记写完后有种似懂非懂的感觉所以这一次我们先看一些具象化的东西在引入概念；

这里以一个商店为例子

```java
//我们由一个货物仓库作为接口
public interface warehouse {
    public abstract void goods();
}

//仓库中现在有三件物品分别是笔、纸和零食
public class pen implements warehouse{
    @Override
    public void goods() {
        System.out.println("In store we have pen");
    }
}

public class paper implements warehouse {
    @Override
    public void goods() {
        System.out.println("In store we have paper");
    }
}

public class eat implements warehouse{
    @Override
    public void goods() {
        System.out.println("In store we have some foods");
    }
}

//商店中售卖的产品和仓库中存储的产品是一致的
public class store {
    //商店展示柜
    public static warehouse getInstance(String Name){
        warehouse m =null;
        if ("pen".equals(Name)){
            m = new pen();
        } else if ("paper".equals(Name)) {
            m = new paper();
        } else if ("eat".equals(Name)) {
            m = new eat();
        }
        return m;
    }

    //模拟顾客购买物品
    public static void main(String[] args) {
        warehouse shop = store.getInstance("pen");
        shop.goods();
    }
}
```

ok上述代码模拟了一个简陋的商店当然没有一个人是不喜欢小钱钱的，所以此时商店的管理员决定要引入一个新的产品fruit水果，如果按照传统模式我们就有大麻烦了水果的加入将打破我们已有的平衡，及我们将修改所有的代码（添加水果类，修改store类中的代码）之后顾客才能够去购买我们的水果，这在一个真实环境中几乎是不可能的，所以我们这里引入了反射如下是利用反射升级的商店

```java
public class store {
    //商店展示柜
    public static warehouse getInstance(String ClassName){
        warehouse m =null;
        try{
            m=(warehouse)Class.forName(ClassName).newInstance();
        }catch (Exception e) {
            e.printStackTrace();
        }
        return m;
    }

    //模拟顾客购买物品
    public static void main(String[] args) {
        warehouse shop = store.getInstance("org.fruit.pen");
        if(shop!=null){
            shop.goods();
        }
    }
}
```

这样搞我们就方便了许多当水果加入货柜时我们只需要创建一个说过类实现warehouse接口即可，与上面的填货方式比较确实是简化了许多；

这也让我们初步了解了反射机制的厉害之处，当然如果你还有些疑惑不妨继续看一下之后的概念；

**因为反射机制的存在我们可以通过修改外部的配置文件，在不修改源码的情况下，来控制程序符合ocp原则（ocp原则：在不修改源码的情况下开扩功能）**

### 概念

反射是java的特征之一，是一种间接操作目标对象的机制，核心是JVM在运行状态的时候才动态加载类，对于任意一个类都能够知道这个类所有的属性和方法，并且对于任意一个对象，都能够调用它的方法/访问属性。这种动态获取信息以及动态调用对象方法的功能成为Java语言的反射机制。通过使用反射我们不仅可以获取到任何类的成员方法(Methods)、成员变量(Fields)、构造方法(Constructors)等信息，还可以动态创建Java类实例、调用任意的类方法、修改任意的类成员变量值等。

我们先编写一个简单的java文件，经过javac编译后产生了.class文件最后，同时jvm内存会查找生成的class文件读入内存和经过类加载器，同时自动创建一个生成一个Class对象，里面拥有其回去的成员变量，成员方法和构造方法等。最后就是我们平时new创建对象；

如图所示：

![image-20230323010652256](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230323010652256.png)



### 编译机制

静态编译：在编译时确定好类型，绑定对象。

动态编译：在运行时确定类型，绑定对象。



### 反射机制相关的主要类

这些类在java.lang.reflect中

java.lang.Class:代表一个类，Class对象表示某个类加载后在堆中的对象；

java.lang.reflect.Method:代表类的方法，Method对象表示某个类的方法；

java.lang.reflect.Field:代表类的成员变量，Field对象表示某个类的成员变量；

java.lang.reflect.Constructor:代表构造方法，Constructor对象表示一个类的构造方法；



### 反射机制中常用的方法

获取类的方法：forname

实例化类对象的方法：newInstance

获取函数的方法：getMethod

执行函数的方法：invoke



#### class对象获取方法

对于一个普通的类来说我们可以使用如下方法来创建实例

```java
Commit commit = new Commit();
```

![image-20230320154955448](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230320154955448.png)

但是再我们创建Class对象时，确无法使用该方法

我们尝试像普通的类一样去实例化Class类

![image-20230320155308015](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230320155308015.png)

可以发现他报错了，我们查看其报错原因

![image-20230320155336540](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230320155336540.png)

我们进入Class文件查看

![image-20230320155717995](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230320155717995.png)

发现其是私有的，只有JVM能够创建Class对象。

##### .classs获取类

如果你已经加载某个类，知识想获取到他的java.lang.Class对象，那么直接拿他的class属性即可（这个方法不属于反射）

```java
Class a = Commit.class;
System.out.println(a.getName());
```



##### 通过getclass()获取类

如果上下文中存在某个实际例obj，那么我们可以直接通过obj.getclass方法来获取他的类

```java
Commit commit = new Commit();
System.out.println(commit.getClass());
```



##### 利用forname()方法获取类

如果你知道某个类的名字，想获取到这个类，就可以使用forname来获取；

```java
Class c = Class.forName("org.fruit.Commit");
System.out.println(c.getName());
```

运行效果如下：

![image-20230321170837608](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230321170837608.png)                 

在实际中常用forname的原因：

由上述的实验中我们可以看出使用类.class属性，需要导入类的包，依赖性太强，在大型项目中容易抛出编译错误；

而使用实例化对象的getClass()方法，需要本身创建一个对象，故失去了反射的意义（通俗来讲就是不方便不动态了）。

所以我们在获取class对象中，一般使用Class.forName方法去获取。



#### 通过对象获取类中的参数

这是之后使用的两个类

```java
package org.fruit;

public class number {
    public  String name = "zero";
    private String name1 = "one";

    //无参构造
    public number() {}

    //有参构造
    public number(String num) {
        this.name = num;
    }

    public void how(){
        System.out.println("I am number:" + name);
    }

     public void hello(){
        System.out.println("have a good day!!!");
    }

}
```

```properties
classfullpath=org.fruit.number
method=how
```

目录结构如下：

![image-20230322213806554](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230322213806554.png)



##### 获取成员变量（java.lang.reflect.Field）

**tips：再利用Filed类的时候无法读取类中的private属性的变量**

这里还有一个有意思的事情我们在传统的获取变量时的语法是`对象.成员变量`而在反射中则是`成员变量.get(对象)`

```java
package org.fruit;

import java.io.FileInputStream;
import java.lang.reflect.Field;
import java.util.Properties;

public class filed {
    //通过Class类获取number类中的成员方法
    public static void main(String[] args) throws Exception{
        //使用properties类，读写配置文件
        Properties properties = new Properties();
        properties.load(new FileInputStream("D:\\Javaeeworkspce\\javasecurity\\src\\main\\java\\org\\test.properties"));
        String classfullpath = properties.get("classfullpath").toString();

        //通过class创建对象，并利用Filed对象获取成员函数
        Class cls = Class.forName(classfullpath);
        Object o = cls.newInstance();
        Field name = cls.getField("name");
        System.out.println(name.getName() + ":" + name.get(o));
    }
}
```

输出结果：

![image-20230322213848446](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230322213848446.png)

zero对应的是变量name其属性是公开的，我们在做一个测试去调用私有的name1看是否能够调用成功

![image-20230322213957241](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230322213957241.png)

我们看到其报错了；



##### 获取构造方法（java.lang.reflect.Constructor)

```java
package org.fruit;

import java.io.FileInputStream;
import java.lang.reflect.Constructor;
import java.util.Properties;

public class constructor {
    public static void main(String[] args) throws Exception{
        //通过Properties获取配置文件类容
        Properties properties = new Properties();
        properties.load(new FileInputStream("D:\\Javaeeworkspce\\javasecurity\\src\\main\\java\\org\\test.properties"));
        String classfullpath = properties.get("classfullpath").toString();


        Class cls = Class.forName(classfullpath);
        Object o = cls.newInstance();
        Constructor constructor = cls.getConstructor();
        System.out.println(constructor);
    }
}
```

获取到了无参构造

![image-20230322234406678](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230322234406678.png)

如果需要获取有参构造我们需要在方法中传入一个形参类的class对象eg:String.class;

![image-20230322235121862](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230322235121862.png)

输出了有参构造器



##### 获取成员函数（java.lang.reflect.Method）

```java
package org.fruit;

import java.io.FileInputStream;
import java.lang.reflect.Method;
import java.util.Properties;

public class func {
    public static void main(String[] args) throws Exception{
        //通过properties获取配置文件
        Properties properties = new Properties();
        properties.load(new FileInputStream("D:\\Javaeeworkspce\\javasecurity\\src\\main\\java\\org\\test.properties"));
        String classfullpath = properties.get("classfullpath").toString();
        String method = properties.get("method").toString();

        Class cls = Class.forName(classfullpath);
        Object o = cls.newInstance();
        Method func = cls.getMethod(method);
        //输出函数名字
        System.out.println("成员方法："+func.getName());
        //执行成员函数
        func.invoke(o);
    }
}
```

我们看到调用了成员函数how

![image-20230323001204161](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230323001204161.png)

这里我们体现一下反射的便捷性，在传统的创建对象过程中如果我们不想使用其中的how方法而是需要使用hello方法，我们需要更改源代码加入一句number.hello(),再将之前的number.how()方法删除，然后将编辑好的代码编译运行然后再一次经过一大串复杂的过程才能实现我们的需求，很显然在一个已经运行的项目中要完成这要的操作是不切实际的这并不满足我们的ocp原则，这也是为什么java的反射机制存在的原因，我们利用反射仅仅需要更改配置即可实现该目的

![image-20230323001947665](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230323001947665.png)

我们可以看到我们仅是将配置文件中的method值由how改为hello，我们的func类输出的结果就与之前大不相同，通过这个例子其实我们就能更深一层的了解，何为“动态”及反射的好处；



#### 反射创建类对象弹计算器

我们可以利用forname配合.newInstance()方法来创建对象

在此之前我们需要了解一下forname函数，forName共有两个重载函数

```java
public static Class<?> forName(String className)
```

![image-20230321230643494](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230321230643494.png)

```java
public static Class<?> forName(String name, boolean initialize,ClassLoader loader)
```

![image-20230321230820417](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230321230820417.png)

默认情况下，forName的第一个参数是类名；第二个参数表示是否初始化；第三个参数就是类加载器（ClassLoader）；

我们需要重点关注中间的第二个参数`boolean initialize`在一些文章中说到，将其设置为true时间，构造函数并不会执行，但根据我们的认知来说构造函数应该是初始化时的首要任务，所以这里我们看一看该参数的存在意义是初始化什么

这里我们先看一些别的东西

```java
package org.fruit;

public class test3_shunxu {
    {
        System.out.printf("Empty Block initial %s\n",this.getClass());
    }

    static {
        System.out.printf("Static initial %s\n", test3_shunxu.class);
    }

    public test3_shunxu(){
        System.out.printf("Initial %s\n", this.getClass());
    }
}
```

![image-20230321232810840](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230321232810840.png)

经过上述的实验显而易见调用顺序是static、{}、构造方法；其中static就是再类初始化的时候调用的，而{}中的代码会放在构造函数的super()后面，但是再当前构造函数内容的前面。

我们可以将该参数理解为类的初始化；







说实话搁着写了半天，其实我还是一脸懵到底都是些啥，所以这里我们写一个简短的利用反射谈计算器的案例

```java
package org.fruit;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class calc {
    public static void main(String[] args) throws ClassNotFoundException, InstantiationException, IllegalAccessException, NoSuchMethodException, InvocationTargetException {
        Class a = Class.forName("java.lang.Runtime");
        Method method = a.getMethod("exec", String.class);
        Method Runtimemethod = a.getMethod("getRuntime");
        Object m = Runtimemethod.invoke(a);

        method.invoke(m,"calc");
    }
}
```

如图我们成功的弹出了计算器：

![image-20230321234456117](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230321234456117.png)

再参照大佬的博客学习时我们同时也学到了关于.newInstance()函数的一些东西

最开始参照大佬的博客源代码如下：

```java
package org.fruit;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class calc {
    public static void main(String[] args) throws ClassNotFoundException, InstantiationException, IllegalAccessException, NoSuchMethodException, InvocationTargetException {
        Class a = Class.forName("java.lang.Runtime");
        Object m = a.newInstance();
        Method method = a.getMethod("exec", String.class);

        method.invoke(m,"calc");
    }
}
```

但是他在创建对象的时候报错了

![image-20230322000314984](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230322000314984.png)

经过查询报错的原因可能是：

1、使用的类没有无参构造函数   2、使用的类构造函数是私有的

根据报错提示我们也确实看到这里是因为后者报错，使用的类构造函数是私有的所以不能使用，然后我们就换了一个方式去执行获取Rumtime类的方法去弹计算器；



参考文章

P牛的文章

B站韩顺平老师的课

[JAVA安全基础（二）-- 反射机制 - 先知社区 (aliyun.com)](https://xz.aliyun.com/t/9117#toc-14)

[JAVA反序列化 - 反射机制 - 先知社区 (aliyun.com)](https://xz.aliyun.com/t/7029#toc-0)