/*
    Iteration:
        //1 -> 2 -> 3 -> 4 -> 5 -> null

        1 -> null  2 -> 3 -> 4 -> 5
        p          t
                   c

        1 -> null  2 -> 3 -> 4 -> 5
        p               t
                        c

        2 -> 1 -> null   3 -> 4 -> 5
                         t
        p                c

        3 -> 2 -> 1 -> null   4 -> 5
                              t
        p                     c

        4 -> 3 -> 2 -> 1 -> null   5
                                   t
        p                          c

        5 -> 4 -> 3 -> 2 -> 1 -> null    null
                                         t
        p                                c

        //5 -> 4 -> 3 -> 2 -> 1
*/

/*
    Recursive
    1 -> 2 -> 3 <- 4 <-5
         k    k+1
*/
namespace LeetCodeRepo
{
    public class Lc206
    {
        public ListNode ReverseList(ListNode head)
        {
            ListNode prev = null;
            ListNode curr = head;
            while (curr != null)
            {
                ListNode temp = curr.next;
                curr.next = prev;
                prev = curr;
                curr = temp;
            }
            return prev;
        }

        public ListNode reverseList(ListNode head){
            if(head == null || head.next == null) return head;
            ListNode p = reverseList(head.next);
            head.next.next = head;
            head.next = null;
            return p;
        }
    }
}