namespace LeetCodeRepo
{
    public class Lc24
    {
        public ListNode SwapPairs(ListNode head)
        {
            if (head == null || head.next == null) return head;
            ListNode first = head;
            ListNode second = head.next;
            first.next = SwapPairs(second.next);
            second.next = first;
            return second;
        }

        public ListNode swapParis(ListNode head)
        {
            ListNode dummy = new ListNode(-1);
            dummy.next = head;
            ListNode prev = dummy;
            while(head != null && head.next !=null){
                ListNode first = head;
                ListNode second = head.next;

                prev.next = second;
                first.next = second.next;
                second.next = first;

                prev = first;
                head = first.next;
            }
            return dummy.next;
        }
    }
}