
/*
          i   
    5, 2, 6, 1
    2, 1, 1, 0

*/

namespace LeetCodeRepo{
    public class Lc315{
        public List<int> CountSmaller(int[] nums){
            int[] ans = new int[nums.Length];
            List<int> sorted = new List<int>();
            for(int i = nums.Length -1; i>=0; i--){
                int idx = BinarySearch(sorted, nums[i]);
                ans[i] = idx;
                sorted.Insert(idx, nums[i]);
            }
            return ans.ToList();
        }

        public int BinarySearch(List<int> sorted, int target){
            int l = 0, r = sorted.Length;
            while(l<r){
                int mid = l + (r-l)/2;
                if(sorted[mid] >= target) r = mid;
                else l = mid+1;
            }
            return l;
        }
    }
}