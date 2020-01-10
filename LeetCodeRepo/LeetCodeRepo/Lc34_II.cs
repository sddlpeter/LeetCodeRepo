/*
    1, 2, 5, 5, 5, 7, 9
    l        m        h

    1, 2, 5, 5, 5, 7, 9
    l  m     h

    1, 2, 5, 5, 5, 7, 9
          l  h
          m

    1, 2, 5, 5, 5, 7, 9
          l
          h

*/


namespace LeetCodeRepo{
    public class Lc34_II{
        public int[] SearchRange(int[] nums, int target){
            int[] targetRange = {-1, -1};
            int leftIdx = extremeInsertionIndex(nums, target, true);
            if(leftIdx == nums.Length || nums[leftIdx] != target) return targetRange;
            targetRange[0] = leftIdx;
            targetRange[1] = extremeInsertionIndex(nums, target, false) -1;
            return targetRange;

        }

        public int extremeInsertionIndex(int[] nums, int target, bool left){
            int lo = 0, hi = nums.Length;
            while(lo<hi){
                int mid = lo + (hi-lo)/2;
                if(nums[mid] > target || (left && target == nums[mid])) hi = mid;
                else lo = mid+1;
            }
            return lo;
        }
    }
}