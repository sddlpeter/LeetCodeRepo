    using System.Collections.Generic;
    
    public class ZigzagIterator
    {

        Queue<int> queue;
        public ZigzagIterator(List<int> v1, List<int> v2)
        {
            queue = new Queue<int>();
            int cnt1 = v1.Count;
            int cnt2 = v2.Count;
            int cnt = cnt1 > cnt2 ? cnt1 : cnt2;
            for(int i = 0; i<cnt; i++)
            {
                if (i < cnt1)
                    queue.Enqueue(v1[i]);
                if (i < cnt2)
                    queue.Enqueue(v2[i]);
            }

        }
        public bool HasNext()
        {
            return queue.Count == 0 ? false : true;
        }

        public int Next()
        {
            return queue.Dequeue();
        }
    }