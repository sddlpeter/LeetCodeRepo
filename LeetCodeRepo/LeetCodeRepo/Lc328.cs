/*
    1 -> 2 -> 3 -> 4 -> 5 -> null
    o    e
    //1st iteration finished
    1 -> 3 -> 4 -> 5 -> null
         o
    2 -> 4 -> 5 -> null
         e
    //2nd iteration finished
    1 -> 3 -> 5 -> null
              o
    2 -> 4 -> null
              e
*/
namespace LeetCodeRepo
{
    public class Lc328
    {
        public ListNode OddEvenList(ListNode head)
        {
            if(head == null) return head;
            ListNode odd = head, even = head.next, evenHead = even;
            while(even!=null && even.next != null){
                odd.next = even.next;
                odd = odd.next;
                even.next = odd.next;
                even = even.next;
            }
            odd.next = evenHead;
            return head;
        }
    }
}