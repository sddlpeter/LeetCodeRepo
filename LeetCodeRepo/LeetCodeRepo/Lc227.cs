using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc227{
        public int Calculate(string s){
            int len = s.Length;
            if(s==null || len == 0) return 0;
            Stack<int> stack = new Stack<int>();
            int num = 0;
            char sign = '+';
            for(int i = 0; i<len; i++){
                if(char.IsDigit(s[i])) num = num*10 + (s[i] - '0');
                if(!char.IsDigit(s[i]) && s[i] != ' ' || i == len-1){
                    if(sign == '-') stack.Push(-num);
                    if(sign == '+') stack.Push(num);
                    if(sign == '*') stack.Push(stack.Pop() * num);
                    if(sign == '/') stack.Push(stack.Pop()/num);
                    sign = s[i];
                    num = 0;
                }
            }
            int res = 0;
            foreach(var i in stack){
                res += i;
            }
        }
    }
}