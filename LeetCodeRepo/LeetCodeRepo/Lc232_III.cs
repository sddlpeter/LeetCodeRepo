using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc232_III{
        private Stack<int> input = new Stack<int>();
        private Stack<int> output = new Stack<int>();
        public void Push(int x){
            input.Push(x);
        }

        public void Pop(){
            Peek();
            output.Pop();
        }

        public int Peek(){
            if(output.Count ==0){
                while(input.Count>0){
                    output.Push(input.Pop());
                }
            }
            return output.Peek();
        }

        public bool Empty(){
            return input.Count == 0 && output.Count == 0;
        }
    }
}