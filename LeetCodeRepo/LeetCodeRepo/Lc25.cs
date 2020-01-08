namespace LeetCodeRepo{
    public class Lc25{
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