namespace LeetCodeRepo
{
    public class Lc82
    {
        public ListNode DeleteDuplicates(ListNode head)
        {
            if(head == null) return head;
            ListNode dummy = new ListNode(0);
            dummy.next = head;
            ListNode prev = dummy, curr = head;
            while(curr!=null){
                while(curr.next != null && curr.val == curr.next.val) curr = curr.next;
                if(prev.next == curr) prev = prev.next;
                else prev.next = curr.next;
                curr = curr.next;
            }
            return dummy.next;
        }
    }
}