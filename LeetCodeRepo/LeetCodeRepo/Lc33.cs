namespace LeetCodeRepo{
    public class Lc33{
        int[] nums;
        int target;
        public int find_rotate_index(int l, int r){
            if(nums[l] < nums[r]) return 0;
            while(l<=r){
                int mid = l + (r-l)/2;
                if(nums[mid] > nums[mid+1]) return mid+1;
                else{
                    if(nums[mid]<nums[l]) r = mid-1;
                    else l = mid+1;
                }
            }
            return 0;
        }
        public int search(int l, int r){
            while(l<=r){
                int mid = l + (r-l)/2;
                if(nums[mid] == target) return mid;
                else{
                    if(nums[mid] > target) r = mid-1;
                    else l = mid +1;
                }
            }
            return -1;
        }

        public int Search(int[] nums, int target){
            this.nums = nums;
            this.target = target;
            int n = nums.Length;
            if(n==0) return -1;
            if(n==1) return this.nums[0] == target ? 0 : -1;
            int rotate_index = find_rotate_index(0, n-1);
            if(nums[rotate_index] == target) return rotate_index;
            if(rotate_index == 0) return search(0, n-1);
            if(target<nums[0]) return search(rotate_index, n-1);
            return search(0, rotate_index);
        }
    }
}