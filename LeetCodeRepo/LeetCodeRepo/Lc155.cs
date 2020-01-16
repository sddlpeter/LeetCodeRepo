using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc155{
        int min = int.MaxValue;
        Stack<int> stack = new Stack<int>();
        public void push(int x){
            if(x<=min){
                stack.Push(min);
                min =x;
            }
            stack.Push(x);
        }

        public void pop(){
            if(stack.Pop() == min) min = stack.Pop();
        }

        public int top(){
            return stack.Peek();
        }

        public int getMin(){
            return min;
        }
    }
}