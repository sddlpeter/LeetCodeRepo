namespace LeetCodeRepo
{
    class InsertionSortSolution
    {
        static void Main(string[] args)
        {
            int[] nums = { 3, 5, 2, 9, 6, 7 };
            var s = new Solution();
            s.print(nums);
            s.InsertionSort(nums);
            s.print(nums);
        }
    }

    public class Solution
    {
        public void InsertionSort(int[] nums)
        {
            int n = nums.Length;
            for (int i = 1; i < n; ++i)
            {
                int key = nums[i];
                int j = i - 1;
                while (j >= 0 && nums[j] > key)
                {
                    nums[j + 1] = nums[j];
                    j--;
                }
                nums[j + 1] = key;
                print(nums);
            }
        }

        public void print(int[] nums)
        {
            foreach (var i in nums)
            {
                Console.Write(i + " ");
            }
            Console.WriteLine();
        }
    }
}