using System;

namespace Class
{
    //
    /* 
     * abstract 抽象类
     * sealed   密封类，不能被继承
     */
    /*
     * public      公开的类，访问不受限制
     * protected   只能由本身或者其派生类访问
     * internal    只能在当前程序中访问
     */
    /*
     * 类的组成
     * 常量 const
     * 字段
     * * 静态字段 static
     * * 实例字段 
     * * 只读字段 readonly
     * * 易失字段 volatile
     * 方法 
     * * params 数组参数调用时也可以写成可变参数的形式
     * * 父类方法必须标注virtual（虚函数，可以被重写的函数） abstract（抽象函数，不实现方法，由子类实现，只能出现在抽象类中） override 子类才能重写该方法
     * 属性 get，set访问器，其中value为set访问器的隐式参数
     * 事件
     * 索引器
     * 运算符
     * 实例构造函数
     * 析构函数
     * 静态构造函数 相当于Java中的static代码块
     * 类型
     */

    class People
    {
        public void firstMethod()
        {
            Console.WriteLine("People::firstMethod");
        }
    }
    class Man : People
    {
        //public override void firstMethod(){ }
        //父类方法必须标注virtual abstract override 子类才能重写该方法
        public string name
        {
            get { return name; }
            set { name = value; }
            //属性
        }
        private string[] list;
        public string this[int index]
        {
            get { return list[index]; }
            set
            {
                if(index > -1 && index < list.Length)
                {
                    list[index] = value;
                }
            }
            //引索器

        }
        public Man(int count)
        {
            list = new string[count];
            for(int i = 1; i <= count; i++)
            {
                list[i-1] = i.ToString();
            }
        }
        public static void Main(string[] args)
        {
            int count = 100;
            Man m = new Man(count);
            for(int i = 0; i < count; i++)
            {
                Console.Write(m[i] + "\t");
                if((i + 1) % 10 == 0)
                {
                    Console.WriteLine();
                }
            }
        }
    }
    class Woman : People
    {

    }

    //internal class Mix : Man, Woman {}
    //不能有多个基类
}