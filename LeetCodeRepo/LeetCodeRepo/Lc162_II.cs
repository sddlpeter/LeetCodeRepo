
/*
    1, 2, 3, 4
    l  m     r

    1, 2, 3, 4
          l  r
          m

    1, 2, 3, 4
             r
             l


    4, 3, 2, 1
    l  m     r


    4, 3, 2, 1
    l  r
    m


    1, 2, 3, 1
    l  m     r

    1, 2, 3, 1
          l  r
*/

namespace LeetCodeRepo{
    public class Lc162_II{
        public int FindPeakElement(int[] nums){
            return search(nums, 0, nums.Length-1);
        }

        public int search(int[] nums, int l, int r){
            if(l==r) return l;
            int mid = l + (r-l)/2;
            if(nums[mid] > nums[mid+1]) return search(nums, l, mid);
            return search(nums, mid+1, r);
        }
    }
}