using System.Collections.Generic;
namespace LeetCodeRepo
{
    public class Lc71
    {
        public string SimplifyPath(string path)
        {
            Stack<string> stack = new Stack<string>();
            HashSet<string> set = new HashSet<string>() { "", ".", ".." };
            string[] strs = path.Split('/');

            foreach (string dir in strs)
            {
                if (dir == ".." && stack.Count > 0) stack.Pop();
                else if (!set.Contains(dir)) stack.Push(dir);
            }

            string res = "";
            foreach (string dir in stack)
            {
                res = "/" + dir + res;
            }
            return res == "" ? "/" : res;
        }
    }
}