using System;
/*
namespace demo
{
    public class Class1
    {
        public interface I
        {
            void hahahaha();
        }
    }
    public class Class2 : Class1
    {
        new public interface I
            //使用关键字new告诉编译器此处是可以要隐藏父类接口I的
        {
            void wuwuwuwuw();
        }
    }
}

namespace demo2
{
    delegate int MyDelegate(int i);
    class Program
    {
        public int square(int n)
        {
            return n * n;
        }
        public static int cubic(int n)
        {
            return n * n * n;
        }
        public static void Main(string[] args)
        {
            MyDelegate Dlgt = new MyDelegate(new Program().square);
            Console.WriteLine(Dlgt(5));
            Dlgt = new MyDelegate(Program.cubic);
            Console.WriteLine(Dlgt(5));
        }
    }
}
*/

    /*
namespace demo3
{
    public delegate double math(double x);
    class Program
    {
        public static double square(double x)
        {
            Console.WriteLine("calling method \"square\"");
            return x * x;
        }
        public static double cubic(double x)
        {
            Console.WriteLine("calling method \"cubic\"");
            return x * x * x;
        }
        public static void Main(string[] args)
        {
            math d1 = new math(square);
            math d2 = new math(cubic);
            math d3 = d1 + d2;
            math d4 = d3 + d2 + d1;
            math d5 = d4 - d1;
            math d6 = d3 + d3 + d4 - d2;
            Console.WriteLine(d1(5));
            Console.WriteLine(d2(5));
            Console.WriteLine(d3(5));
            Console.WriteLine(d4(5));
            Console.WriteLine(d5(5));
            Console.WriteLine(d6(5));
        }
    }
}

    */
/*
namespace exceptionDemo
{
    public class MyException : Exception
    {
        private string msg;

        public string message
        {
            get
            {
                return msg;
            }
            set
            {
                msg = value;
            }
        }

        public MyException(string message)
        {
            this.message = message;
        }
        
    }
    class Program
    {
        public static int Func(int n)
        {
            if(n == 0)
            {
                throw new MyException("whattttttt?");
            }
            return n;
        }
        public static void Main(string[] args)
        {
            int a = 1000;
            int n = 20;
            for (; n >= 0; n--)
            {
                try
                {
                    Console.WriteLine(a / n);
                    Console.WriteLine(Func(20 - n));
                }
                catch (MyException me)
                {
                    Console.WriteLine(me.message);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                    Console.WriteLine(e.ToString());
                }   
            }
        }
    }
}

*/

namespace demo
{
    public delegate void mDlgt(ref int i, ref int j);
    public class Program
    {
        public static void swap<U>(ref U a, ref U b)
        {
            U temp = a;
            a = b;
            b = temp;
        }
        public static void Main(string[] args)
        {
            mDlgt d = new mDlgt(swap<int>);
        }
    }
}