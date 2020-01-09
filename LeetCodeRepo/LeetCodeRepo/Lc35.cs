namespace LeetCodeRepo{
    public class Lc35{
        public int SearchInsert(int[] nums, int target){
            int l = nums[0], r = nums[nums.Length-1];
            while(l<=r){
                int mid = l + (r-l)/2;
                if(nums[mid]<target)
                    l = mid+1;
                else
                    r = mid-1;
            }
            return l;
        }
    }
}