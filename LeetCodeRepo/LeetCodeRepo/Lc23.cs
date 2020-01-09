using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc23{
        public ListNode MergeKLists(ListNode[] lists){
            List<int> l = new List<int>();
            for(int i = 0; i<lists.Length; i++){
                while(lists[i]!=null){
                    l.Add(lists[i].val);
                    lists[i] = lists[i].next;
                }
            }
            int[] nums = l.ToArray();
            Array.Sort(nums);
            ListNode dummy = new ListNode(0);
            ListNode curr = dummy;
            foreach(var i in nums){
                ListNode t = new ListNode(i);
                curr.next = t;
                curr = curr.next;
            }
            return dummy.next;
        }
    }
}