
//  1 -> 2 -> 4 -> 3
//  p    q
//  t

namespace LeetCodeRepo{
    public class Lc147{
        public ListNode InsertionSortList(ListNode head){
            if(head == null) return null;
            ListNode q = head.next;
            ListNode p;
            while(q!=null){
                p = head;
                while(q!=null && p!=q && q.val > p.val) p = p.next;
                while(q!=null && p!=q && q.val <= p.val){
                    int temp = p.val;
                    p.val = q.val;
                    q.val = temp;
                    p = p.next;
                }
                q = q.next;
            }
            return head;
        }
    }
}