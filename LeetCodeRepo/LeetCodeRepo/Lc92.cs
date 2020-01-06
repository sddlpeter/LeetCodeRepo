/*
    1 -> 2 -> 3 -> 4 -> 5  m = 2, n = 4
    c

    1 -> 2 -> 3 -> 4 -> 5  m = 1, n = 3
    p    c
    con  tail


    1 -> 2 -> 3 -> 4 -> 5  m = 1, n = 3
    p    c    t
    con  tail

    1 <- 2    3 -> 4 -> 5  m = 1, n = 2
         p    c
    con  tail

    1 <- 2 <- 3    4 -> 5  m = 1, n = 1
              p    c
    con  tail

    1 <- 2 <- 3 <- 4    5  m = 1, n = 0
                   p    c
    con  tail


    1 -> 4 -> 3 -> 2 -> 5  m = 1, n = 0
    con  p         tail c

*/


namespace LeetCodeRepo
{
    public class Lc92
    {
        public ListNode ReverseBetween(ListNode head, int m, int n)
        {
            if (head == null) return null;
            ListNode curr = head, prev = null;
            while (m > 1)
            {
                prev = curr;
                curr = curr.next;
                m--;
                n--;
            }
            ListNode con = prev, tail = curr;
            ListNode temp = null;
            while (n > 0)
            {
                temp = curr.next;
                curr.next = prev;
                prev = curr;
                curr = temp;
                n--;
            }
            if (con != null) con.next = prev;
            else head = prev;
            tail.next = curr;
            return head;
        }
    }
}