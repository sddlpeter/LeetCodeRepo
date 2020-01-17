namespace LeetCodeRepo
{
    public class Lc388
    {
        public int LengthLongestPath(string input)
        {
            Stack<int> stack = new Stack<int>();
            stack.Push(0);
            int maxLen = 0;
            string[] paths = input.Split('\n');

            foreach (string s in paths)
            {
                int lev = s.LastIndexOf("\t") + 1;
                while (lev + 1 < stack.Count) stack.Pop();
                int len = stack.Peek() + s.Length - lev + 1;
                stack.Push(len);
                if (s.Contains(".")) maxLen = Math.Max(maxLen, len - 1);
            }
            return maxLen;
        }
    }
}