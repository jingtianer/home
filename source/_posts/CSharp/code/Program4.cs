using System;

namespace Struct
{
    public struct stu
    {
        public stu(int age, string sex, int id)
        {
            this.age = age;
            this.sex = sex;
            this.id = id;
            this.uuid = age.ToString() + sex + id.ToString();
        }
        public int age;
        public string sex;
        public int id;
        private string uuid;

        public override string ToString()
        {
            return base.ToString() + "\n" + 
                "{age   = " + age + "}," +
                "{sex   = " + sex + "}," + 
                "{id    = " + id + "}," + 
                "{uuid  = " + uuid + "}";
        }
        public void setValue(stu s)
        {
            this = s;
        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            stu s = new stu(19, "female", 1);
            stu s1 = new stu(20, "male", 2);
            Console.WriteLine("s = " + s.ToString());
            Console.WriteLine("s1 = " + s1.ToString());
            s.setValue(s1);
            Console.WriteLine("s1 = " + s);
        }
    }
}
