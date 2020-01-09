namespace LeetCodeRepo{
    public class Lc23_IV{
        public ListNode MergeKLists(ListNode[] lists){
            if(lists.Length == 1) return lists[0];
            if(lists.Length == 0) return null;
            ListNode head = MergeTwoLists(lists[0], lists[1]);
            for(int i = 2; i<lists.Length; i++){
                head = MergeTwoLists(head, lists[i]);
            }
            return head;
        }

        public ListNode MergeTwoLists(ListNode l1, ListNode l2){
            ListNode h = new ListNode(0);
            ListNode ans = h;
            while(l1 != null && l2!=null){
                if(l1.val < l2.val){
                    h.next = l1;
                    l1 = l1.next;
                }else{
                    h.next = l2;
                    l2 = l2.next;
                }
                h = h.next;
            }
            if(l1 == null) h.next = l2;
            if(l2 == null) h.next = l1;
            return ans.next;
        }
    }
}