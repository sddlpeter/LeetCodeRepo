namespace LeetCodeRepo
{
    public class Lc224
    {
        public int Calculate(string s)
        {
            int operand = 0;
            int n = 0;
            Stack<int> stack = new Stack<int>();
            for (int i = s.Length - 1; i >= 0; i--)
            {
                char ch = s[i];
                if (char.IsDigit(ch))
                {
                    operand = (int)Math.Pow(10, n) * (int)(ch - '0') + operand;
                    n += 1;
                }
                else if (ch != ' ')
                {
                    if (n != 0)
                    {
                        stack.Push(operand);
                        n = 0;
                        operand = 0;
                    }
                    if (ch == '(')
                    {
                        int res = evaluateExpr(stack);
                        stack.Pop();
                        stack.Push(res);
                    }
                    else
                    {
                        stack.Push(ch);
                    }
                }
            }
            if (n != 0) stack.Push(operand);
            return evaluateExpr(stack);
        }

        public int evaluateExpr(Stack<int> stack)
        {
            int res = 0;
            if (stack.Count > 0)
                res = (int)stack.Pop();
            while (stack.Count > 0 && !((char)stack.Peek() == ')'))
            {
                char sign = (char)stack.Pop();
                if (sign == '+')
                    res += (int)stack.Pop();
                else
                    res -= (int)stack.Pop();
            }
            return res;
        }
    }

    public class Lc224_II
    {
        public int Calculate(string s)
        {
            Stack<int> stack = new Stack<int>();
            int operand = 0;
            int result = 0;
            int sign = 1;
            for (int i = 0; i < s.Length; i++)
            {
                char ch = s[i];
                if (char.IsDigit(ch))
                {
                    operand = 10 * operand + (int)(ch - '0');
                }
                else if (ch == '+')
                {
                    result += sign * operand;
                    sign = 1;
                    operand = 0;
                }
                else if (ch == '-')
                {
                    result += sign * operand;
                    sign = -1;
                    operand = 0;
                }
                else if (ch == '(')
                {
                    stack.Push(result);
                    stack.Push(sign);
                    sign = 1;
                    result = 0;
                }
                else if (ch == ')')
                {
                    result += sign * operand;
                    result *= stack.Pop();
                    result += stack.Pop();
                    operand = 0;
                }
            }
            return result + (sign * operand);
        }
    }
}