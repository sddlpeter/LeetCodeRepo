namespace LeetCodeRepo{
    public class Lc143{
        public void ReorderList(ListNode head){
            if(head == null || head.next == null) return head;
            ListNode slow = head;
            ListNode fast = head;
            while(fast.next != null && fast.next.next != null){
                fast = fast.next.next;
                slow = slow.next;
            }

            ListNode prev = null;
            ListNode curr = slow.next;
            while(curr!=null){
                ListNode temp = curr.next;
                curr.next = prev;
                prev = curr;
                curr = temp;
            }
            slow.next = prev;

        }
    }
}