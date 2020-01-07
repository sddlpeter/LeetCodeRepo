/*
    1 -> 2 -> 3 -> 4 -> 5 -> 6
    s
    f

    1 -> 2 -> 3 -> 4 -> 5 -> 6
         s
              f

    1 -> 2 -> 3 -> 4 -> 5 -> 6 -> null
              s
                        f

    1 -> 2 -> 3 -> 4 -> 5 -> 6 -> null
              pM
                   pC

    1 -> 2 -> 3 -> 4 -> 5 -> 6 -> null
              pM
                   pC   c
*/

namespace LeetCodeRepo{
    public class Lc143{
        public void ReorderList(ListNode head){
            if(head == null || head.next == null) return;
            ListNode slow = head;
            ListNode fast = head;
            while(fast.next != null && fast.next.next != null){
                fast = fast.next.next;
                slow = slow.next;
            }

            ListNode firstHalfEnd = slow;
            ListNode secondHalfStart = slow.next;
            //  1 -> 2 -> 3 -> 4 -> 5 -> 6 -> null
            //            f    s    c

            //  1 -> 2 -> 3 -> 5 -> 4 -> 6 -> null
            //            f         s    c

            //  1 -> 2 -> 3 -> 6 -> 5 -> 4 -> null
            //            f              s    c
            while(secondHalfStart.next != null){
                ListNode curr = secondHalfStart.next;
                secondHalfStart.next = curr.next;
                curr.next = firstHalfEnd.next;
                firstHalfEnd.next = curr;
            }

            //  1 -> 2 -> 3 -> 6 -> 5 -> 4 -> null
            //  p1        f    p2

            //  1 -> 6 -> 2 -> 3 -> 5 -> 4 -> null

            ListNode p1 = head;
            ListNode p2 = firstHalfEnd.next;
            while(p1!=firstHalfEnd){
                firstHalfEnd.next = p2.next;
                p2.next = p1.next;
                p1.next = p2;
                p1 = p2.next;
                p2 = firstHalfEnd.next;
            }
        }
    }
}