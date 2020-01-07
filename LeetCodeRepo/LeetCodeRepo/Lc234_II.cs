namespace LeetCodeRepo{
    public class Lc234_II{
        private ListNode frontPointer;
        public bool IsPalindrome(ListNode head){
            frontPointer = head;
            return helper(head);
        }
        public bool helper(ListNode curr){
            if(curr!=null){
                if(!helper(curr.next)) return false;
                if(frontPointer.val != curr.val) return false;
                frontPointer = frontPointer.next;
            }
            return true;
        }
    }
}