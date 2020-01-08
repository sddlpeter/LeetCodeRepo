using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc23{
        public ListNode MergeKLists(ListNode[] lists){
            List<int> l = new List<int>();
            foreach(ListNode node in lists){
                while(node!=null){
                    l.Add(node.val);
                    node = node.next;
                }
            }

            Array.sort(l);
            ListNode head = new ListNode(0);
            ListNode h = head;
            foreach(int i in l){
                ListNode t = new ListNode(i);
                h.next = t;
                h = h.next;
            }
            h.next = null;
            return head.next;
        }
    }
}