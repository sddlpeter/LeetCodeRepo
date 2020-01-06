namespace LeetCodeRepo{
    public class Lc19{
        public ListNode RemoveNthFromEnd(ListNode head, int n){
            ListNode dummy = new ListNode(0);
            dummy.next = head;
            ListNode first = dummy;
            ListNode second = dummy;
            while(n>0){
                first = first.next;
                n--;
            }
            while(first!=null){
                first = first.next;
                second = second.next;
            }
            second.next = second.next.next;
            return dummy.next;
        }
    }
}