using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LeetCodeRepo
{
    public class Lc141
    {
        public bool HasCycle(ListNode head)
        {
            HashSet<ListNode> set = new HashSet<ListNode>();
            while (head != null)
            {
                if (set.Contains(head)) return true;
                else set.Add(head);
                head = head.next;
            }
            return false;
        }


        public bool hasCycle(ListNode head)
        {
            if(head == null || head.next == null) return false;
            ListNode slow = head;
            ListNode fast = head.next;
            while(slow!=fast){
                if(fast==null || fast.next == null) return false;
                slow = slow.next;
                fast = fast.next.next;
            }
            return true;
        }
    }
}