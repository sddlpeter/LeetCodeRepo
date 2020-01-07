namespace LeetCodeRepo{
    public class Lc234{
        public bool IsPalindrome(ListNode head){
            List<int> val = new List<int>();
            ListNode curr = head;
            while(curr != null){
                val.Add(curr.val);
                curr = curr.next;
            }

            int l = 0, r = val.Count -1;
            while(l<r){
                if(val[l] != val[r]) return false;
                l++;
                r--;
            }
            return true;
        }
    }
}