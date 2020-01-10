namespace LeetCodeRepo{
    public class Lc154{
        public int FindMin(int[] nums){
            int low = 0, high = nums.Length-1;
            while(low<high){
                int mid = low + (high-low)/2;
                if(nums[mid] < nums[high]) high = mid;
                else if(nums[mid] > nums[high]) low = mid +1;
                else high--;
            }
            return nums[low];
        }
    }
}