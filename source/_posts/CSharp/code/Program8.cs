/*
using System;

namespace HelloCS8
{
    public class Stu
    {
        public int age;//想在构造器中初始化，必须public
                        //（如果被其他类调用）（等价于直接访问）
        public string name;
    }
    class Program
    {
        private int age;
        protected string name;
        static void Main(string[] args)
        {
            Stu s = new Stu
            {
                age = 10,//注意这里用,
                name = "啊哈哈"//这里不用分好

            };//这里要加分号
//            
//              等价于以下写法
//              Stu s = new Stu();
//              s.age = 10;
//              s.name = "啊哈哈";
//             
            Program pro = new Program
            {
                age = 11,//同一个类中,可在构造器中对非public赋值
                name = "哇咔咔"
            };
        }
    }
}
*/
/*
using System;
using System.Collections.Generic;
namespace collection
{
    class Program
    {
        public static void Main(string[] args)
        {
            List<int> arr = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 };
            foreach(var item in arr)
            {
                Console.WriteLine(item);
            }
        }
    }
}
*/
/*
using System;
using System.Collections.Generic;
namespace AnonymousClass
{
    class Program
    {
        class item
        {
            public int ItemID;
            public string ItemName;
            public override string ToString()
            {
                return base.ToString() + "\n{ ItemID = " + ItemID + ", ItemName" + ItemID + "}";
            }
        }
        static void Main(string[] args)
        {
            var Ac = new
            {
                ID = 1,
                Name = "哇耶耶",
                Sex = "Female",
                arr = new List<item>
                {
                    new item
                    {
                        ItemID = 0,
                        ItemName = "小猫"
                    },
                    new item
                    {
                        ItemID = 1,
                        ItemName = "大猫"
                    },
                    new item
                    {
                        ItemID = 2,
                        ItemName = "男朋友"
                    }
                }
            };
            Console.WriteLine("GetType : " + Ac.GetType());
            Console.WriteLine("ID      = " + Ac.ID);
            Console.WriteLine("Name    = " + Ac.Name);
            Console.WriteLine("Sex     = " + Ac.Sex);
            var arr = Ac.arr;
            foreach(var item in arr)
                Console.WriteLine(item);
        }
    }
}
*/
/*
using System;
namespace equal
{
    class Program
    {
        static void Main(string[] args)
        {
            var AC = new { ID = 0, Name = "哈哈哈" };
        }
    }
}
*/
/*
using System;
namespace equal
{
    class EQUAL
    {
        private int f1;
        private string f2;
        public EQUAL(int a1, string a2)
        {
            f1 = a1;
            f2 = a2;
        }
        public int ID { get { return f1; } set { f1 = value; } }
        public string Name { get { return f2; } set { f2 = value; } }
    }
    class Program
    {
        static void Main(string[] args)
        {
            var AC = new EQUAL(0, "哈哈哈");
        }
    }
}
*/

using System;
namespace ACArr
{
    class Program
    {
        static void Main(string[] args)
        {
            var arr = new[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
            foreach(var item in arr)
            {
                Console.WriteLine(item);
            }
        }
    }
}