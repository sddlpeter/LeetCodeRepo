using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc232_II{
        private Stack<int> s1 = new Stack<int>();
        private Stack<int> s2 = new Stack<int>();
        private int front;
        public void Push(int x){
            if(s1.Count == 0) front = x;
            s1.Push(x);
        }

        public int Pop(){
            if(s2.Count == 0){
                while(s1.Count>0){
                    s2.Push(s1.Pop());
                }
            }
            return s2.Pop();
        }

        public bool Empty(){
            return s1.Count == 0 && s2.Count == 0;
        }

        public int Peek(){
            if(s2.Count>0) return s2.Peek();
            return front;
        }
    }
}