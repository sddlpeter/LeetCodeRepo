using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc225{
        private Queue<int> q1 = new Queue<int>();
        private Queue<int> q2 = new Queue<int>();
        private int top;
        public void Push(int x){
            q1.Enqueue(x);
            top = x;
        }

        public void Pop(){
            while(q1.Count>1){
                top = q1.Dequeue();
                q2.Enqueue(top);
            }
            q1.Dequeue();
            Queue<int> temp = q1;
            q1 = q2;
            q2 = temp;
        }

        public int Top(){
            return top;
        }

        public bool Empty(){
            return q1.Count>0;
        }
    }


    public class Lc225_II{
        private Queue<int> q1 = new Queue<int>();
        private Queue<int> q2 = new Queue<int>();
        private int top;
        public void Push(int x){
            q2.Enqueue(x);
            top = x;
            while(q1.Count>0){
                q2.Enqueue(q1.Dequeue());
            }
            Queue<int> temp = q1;
            q1 = q2;
            q2 = temp;
        }

        public void Pop(){
            q1.Dequeue();
            if(q1.Count >0){
                top = q1.Peek();
            }
        }

        public bool Empty(){
            return q1.Count == 0;
        }

        public int Top(){
            return top;
        }
    }
}