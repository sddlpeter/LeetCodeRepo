namespace LeetCodeRepo{
    public class Lc25_II{
        //  1 -> 2 -> 3 -> 4 -> 5 -> null
        //  2 -> 1 -> 4 -> 3 -> 5    when k == 2


        //  p -> 1 -> 2 -> 3 -> 4 -> 5 -> null
        //       t         n
        //  2 -> 1 -> 4 -> 3 -> 5    when k == 2
        public ListNode ReverseKGroup(ListNode head, int k){
            int n = 0;
            for(ListNode curr = head; curr != null; n++, curr = curr.next);

            ListNode dummy = new ListNode(0);
            dummy.next = head;
            for(ListNode prev = dummy, tail = head; n >= k; n-=k){
                for(int i = 1; i<k; i++){
                    ListNode next = tail.next.next;
                    tail.next.next = prev.next;
                    prev.next = tail.next;
                    tail.next = next;
                }
                prev = tail;
                tail = tail.next;
            }
            return dummy.next;
        }
    }
}