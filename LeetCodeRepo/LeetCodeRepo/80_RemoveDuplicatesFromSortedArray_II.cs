public class _80_RemoveDuplicatesFromSortedArray_II
{
    public int RemoveDuplicates(int[] nums)
    {
        if(nums.Length<=2) return nums.Length;
        int i = 1, count = 1;
        for (int j = 1; j < nums.Length; j++)
        {
            if (nums[j] == nums[j - 1])
            {
                count++;
            }
            else
            {
                count = 1;
            }
            if (count <= 2) nums[i++] = nums[j];
        }
        return i;
    }
}