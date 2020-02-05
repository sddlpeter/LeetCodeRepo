using System.Collections.Generic;
using System;

namespace LeetCodeRepo
{
    public class _382
    {
        ListNode head;
        Random rand;

        public _382(ListNode h)
        {
            head = h;
            rand = new Random();
        }

        public int GetRandom()
        {
            ListNode c = head;
            int r = c.val;
            for (int i = 1; c.next != null; i++)
            {
                c = c.next;
                if (rand.Next(i + 1) == i) r = c.val;
            }
            return r;
        }
    }

    public class ListNode{
        public int val;
        public ListNode next;
    }
}