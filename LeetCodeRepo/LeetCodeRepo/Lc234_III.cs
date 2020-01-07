namespace LeetCodeRepo{
    public class Lc234_III{
        public bool IsPalindrome(ListNode head){
            if(head == null) return true;
            ListNode firstHalfEnd = endOfFirstHalf(head);
            ListNode secondHalfStart = reverseList(firstHalfEnd.next);
            ListNode p1 = head;
            ListNode p2 = secondHalfStart;
            bool result = true;
            while(result && p2!=null){
                if(p1.val != p2.val) result = false;
                p1 = p1.next;
                p2 = p2.next;
            }

            //restore the list
            firstHalfEnd.next = reverseList(secondHalfStart);
            return result;
        }

        private ListNode reverseList(ListNode head){
            ListNode curr =head;
            ListNode prev = null;
            while(curr!=null){
                ListNode temp = curr.next;
                curr.next = prev;
                prev = curr;
                curr = temp;
            }
            return prev;
        }

        private ListNode endOfFirstHalf(ListNode head){
            ListNode fast = head;
            ListNode slow = head;
            while(fast.next != null && fast.next.next != null){
                fast = fast.next.next;
                slow = slow.next;
            }
            return slow;
        }
    }
}