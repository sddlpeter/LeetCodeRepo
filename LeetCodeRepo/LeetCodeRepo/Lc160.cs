namespace LeetCodeRepo{
    public class Lc160{
        public ListNode GetIntersectionNode(ListNode headA, ListNode headB){
            ListNode l1 = headA, l2 = headB;
            if(l1 == null && l2 == null) return null;
            while(l1!=l2){
                l1 = l1 == null ? headB : l1.next;
                l2 = l2 == null ? headA : l2.next;
            }
            return l1;
        }
    }
}