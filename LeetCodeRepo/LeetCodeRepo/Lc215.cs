/*
arr[] = {10, 80, 30, 90, 40, 50, 70}
Indexes:  0   1   2   3   4   5   6 

*/


namespace LeetCodeRepo
{
    public class Lc215
    {
        public int FindKthLargest(int[] nums, int k)
        {
            k = nums.Length - k;
            int lo = 0;
            int hi = nums.Length - 1;
            while (lo < hi)
            {
                int j = partition(nums, lo, hi);
                if (j < k) lo = j + 1;
                else if (j > k) hi = j - 1;
                else break;
            }
            return nums[k];
        }

        private int partition(int[] nums, int lo, int hi)
        {
            int pivot = nums[hi];
            int i = lo;
            for (int j = lo; j < hi; j++)
            {
                if (nums[j] <= pivot)
                {
                    swap(nums, i, j);
                    i++;
                }
            }
            swap(nums, i, hi);
            return i;
        }

        public void swap(int[] nums, int i, int j)
        {
            int temp = nums[i];
            nums[i] = nums[j];
            nums[j] = temp;
        }
    }
}