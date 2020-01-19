// failed on submit, passed run code

using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc385{
        public NestedInteger Deserialize(string s){
            if(!s.StartsWith("[")) return new NestedInteger(int.Parse(s));
            Stack<NestedInteger> stack = new Stack<NestedInteger>();
            NestedInteger res = new NestedInteger();
            stack.Push(res);
            int start = 1;
            for(int i = 1; i<s.Length; i++){
                char c = s[i];
                if(c == '['){
                    NestedInteger ni = new NestedInteger();
                    stack.Peek().Add(ni);
                    stack.Push(ni);
                    start = i+1;
                } else if(c == ',' || c == ']'){
                    if(i>start){
                        int val = int.Parse(s.Substring(start, i));
                        stack.Peek().Add(new NestedInteger(val));
                    }
                    start = i+1;
                    if(c == ']') stack.Pop();
                }
            }
            return res;
        }
    }
}