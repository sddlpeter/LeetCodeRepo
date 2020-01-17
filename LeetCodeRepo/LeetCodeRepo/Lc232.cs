using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc232{
        public Stack<int> stack = new Stack<int>();
        public Stack<int> bkp = new Stack<int>();
        public void Push(int x){
            while(stack.Count>0){
                bkp.Push(stack.Pop());
            }
            bkp.Push(x);
            while(bkp.Count>0){
                stack.Push(bkp.Pop());
            }
        }

        public int Pop(){
            return stack.Pop();
            
        }

        public bool Empty(){
            return stack.Count==0;
        }

        public int Peek(){
            return stack.Peek();
        }
    }
}