using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc142{
        public ListNode DetectCycle(ListNode head){
            HashSet<ListNode> visited = new HashSet<ListNode>();
            ListNode node = head;
            while(node!=null){
                if(visited.Contains(node)) return node;
                visited.Add(node);
                node = node.next;
            }
            return null;
        }
    }
}