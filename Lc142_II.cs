namespace LeetCodeRepo{
    public class Lc142_II{
        public ListNode GetIntersect(ListNode head){
            ListNode slow = head;
            ListNode fast = head;
            while(fast!=null && fast.next !=null){
                slow = slow.next;
                fast = fast.next.next;
                if(slow == fast) return slow;
            }
            return null;
        }

        public ListNode DetectCycle(ListNode head){
            if(head == null) return null;
            ListNode intersect = GetIntersect(head);
            if(intersect == null) return null;

            ListNode p1 = head;
            ListNode p2 = intersect;
            while(p1 != p2){
                p1 = p1.next;
                p2 = p2.next;
            }
            return p1;
        }
    }
}