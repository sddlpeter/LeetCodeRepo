
// compare one by one
// O(n) space
namespace LeetCodeRepo{
    public class Lc23_II{
        public ListNode MergeKLists(ListNode[] lists){
            int min_index = 0;
            ListNode head = new ListNode(0);
            ListNode h = head;
            while(true){
                bool IsBreak = true;
                int min = int.MaxValue;
                for(int i = 0; i<lists.Length; i++){
                    if(lists[i] != null){
                        if(lists[i].val < min){
                            min = lists[i].val;
                            min_index = i;
                        }
                        IsBreak = false;
                    }
                }
                if(IsBreak) break;
                ListNode a = new ListNode(lists[min_index].val);
                h.next = a;
                h = h.next;
                lists[min_index] = lists[min_index].next;
            }
            h.next = null;
            return head.next;
        }

        //O(1) space
        public ListNode MergeKLists2(ListNode[] lists){
            int min_index = 0;
            ListNode head = new ListNode(0);
            ListNode h = head;
            while(true){
                bool IsBreak = true;
                int min = int.MaxValue;
                for(int i = 0; i<lists.Length; i++){
                    if(lists[i] != null){
                        if(lists[i].val< min){
                            min = lists[i].val;
                            min_index = i;
                        }
                        IsBreak = false;
                    }
                }
                if(IsBreak) break;
                h.next = lists[min_index];
                h = h.next;
                lists[min_index] = lists[min_index].next;
            }
            h.next = null;
            return head.next;

        }
    }
}