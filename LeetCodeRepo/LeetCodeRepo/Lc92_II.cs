namespace LeetCodeRepo
{
    public class Lc92_II
    {
        private bool stop;
        private ListNode left;
        public ListNode ReverseBetween(ListNode head, int m, int n)
        {
            this.left = head;
            this.stop = false;
            this.recurseAndReverse(head, m, n);
            return head;
        }

        public void recurseAndReverse(ListNode right, int m, int n)
        {
            if(n==1) return;
            right = right.next;
            if(m>1) this.left = this.left.next;
            this.recurseAndReverse(right, m-1, n-1);
            if(this.left == right || right.next == this.left) this.stop = true;
            if(!this.stop){
                var t = this.left.val;
                this.left.val = right.val;
                right.val = t;
                this.left = this.left.next;
            }
        }
    }
}