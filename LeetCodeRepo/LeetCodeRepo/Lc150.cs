namespace LeetCodeRepo
{
    public class Lc150
    {
        public int EvalRPN(string[] tokens)
        {
            int a, b;
            Stack<int> stack = new Stack<int>();
            foreach (string s in tokens)
            {
                if (s == "+")
                {
                    stack.Push(stack.Pop() + stack.Pop());
                }
                else if (s == "/")
                {
                    a = stack.Pop();
                    b = stack.Pop();
                    stack.Push(b / a);
                }
                else if (s == "*")
                {
                    stack.Push(stack.Pop() * stack.Pop());
                }
                else if (s == "-")
                {
                    a = stack.Pop();
                    b = stack.Pop();
                    stack.Push(b - a);
                }
                else
                {
                    stack.Push(int.Parse(s));
                }
            }
            return stack.Pop();
        }
    }
}