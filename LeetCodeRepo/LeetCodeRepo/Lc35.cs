
/*

    1, 3, 5, 6     target = 2;
    l = 0, r = 3 mid = 1
    l = 0, r = 0 mid = 0
    l = 1, r = 0

*/
namespace LeetCodeRepo{
    public class Lc35{
        public int SearchInsert(int[] nums, int target){
            int l = 0, r = nums.Length-1;
            while(l<=r){
                int mid = l + (r-l)/2;
                if(nums[mid]<target)
                    l = mid+1;
                else r = mid-1;
            }
            return l;
        }
    }
}