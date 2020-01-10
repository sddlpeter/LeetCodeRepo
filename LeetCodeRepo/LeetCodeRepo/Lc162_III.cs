/*
    1, 2, 3, 4, 3, 1, 2
    l        m        r

    1, 2, 3, 4, 3, 1, 2
    l  m     r

    1, 2, 3, 4, 3, 1, 2
          l  r
          m

    1, 2, 3, 4, 3, 1, 2
          l  r
          m
*/





namespace LeetCodeRepo{
    public class Lc162_III{
        public int FindPeakElement(int[] nums){
            int l = 0, r = nums.Length-1;
            while(l<r){
                int mid = l + (r-l)/2;
                if(nums[mid]>nums[mid+1]) r = mid;
                else l =mid+1;
            }
            return l;
        }
    }
}