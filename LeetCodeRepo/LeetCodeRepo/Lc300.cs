/*
    [10,9,2,5,3,7,101,18]


*/


namespace LeetCodeRepo{
    public class Lc300{
        public int LengthOfLIS(int[] nums){
            return helper(nums, int.MinValue, 0);
        }
        public int helper(int[] nums, int prev, int curpos){
            if(curpos == nums.Length) return 0;
            int take = 0;
            if(nums[curpos]>prev) taken = 1 + helper(nums, nums[curpos], curpos+1);
            int nottaken = helper(nums, prev, curpos+1);
            return Math.max(taken, nottaken);
        }
    }
}