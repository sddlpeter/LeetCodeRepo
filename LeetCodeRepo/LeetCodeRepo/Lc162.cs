namespace LeetCodeRepo{
    public class Lc162{
        public int FindPeakElements(int[] nums){
            for(int i = 0; i<nums.Length; i++){
                if(nums[i]>nums[i+1]) return i;
            }
            return nums.Length-1;
        }
    }
}