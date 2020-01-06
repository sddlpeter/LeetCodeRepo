namespace LeetCodeRepo
{
    public class Lc2
    {
        public ListNode AddTwoNumers(ListNode l1, ListNode l2)
        {
            ListNode dummy = new ListNode(0);
            ListNode p = l1, q = l2, curr = dummy;
            int carry = 0;
            while(p!=null || q!=null){
                int x = p!=null ? p.val : 0;
                int y = q!=null ? q.val : 0;
                int sum = carry + x + y;
                carry = sum/10;
                curr.next = new ListNode(sum%10);
                curr = curr.next;
                if(carry>0) curr.next = new ListNode(carry);
                if(p!=null) p = p.next;
                if(q!=null) q = q.next;
            }
            return dummy.next;
        }
    }
}