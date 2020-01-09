namespace LeetCodeRepo{
    public class Lc81{
        public bool Search(int[] nums, int target){
            int start = 0, end = nums.Length-1;
            while(start<=end){
                int mid = start + (end-start)/2;
                if(nums[mid] == target) return true;
                else if(nums[mid] < nums[end] || nums[mid] < nums[start]){
                    if(target <=nums[end] && target > nums[mid]) start = mid+1;
                    else end = mid-1;
                }else if(nums[mid] > nums[end] || nums[mid] > nums[start]){
                    if(target<nums[mid] && target >= nums[start]) end = mid-1;
                    else start = mid+1;
                } else end--;
            }
            return false;
        }
    }
}