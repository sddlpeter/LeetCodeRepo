namespace LeetCodeRepo{
    public class Lc25{
        //  1 -> 2 -> 3 -> 4 -> 5 -> null
        //  2 -> 1 -> 4 -> 3 -> 5 when k == 2
        public ListNode ReverseKGroup(ListNode head, int k){
            ListNode curr = head;
            int count = 0;
            while(curr != null && count != k){
                curr = curr.next;
                count++;
            }
            if(count == k){
                curr = ReverseKGroup(curr, k);
                while(count-- > 0){
                    ListNode temp = head.next;
                    head.next = curr;
                    curr = head;
                    head = temp;
                }
                head = curr;
            }
            return head;
        }
    }
}