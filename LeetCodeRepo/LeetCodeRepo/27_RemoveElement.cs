
    public class _27_RemoveElement
    {
        public int RemoveElement(int[] nums, int value)
        {
            int i = 0;
            for(int j = 0; j < nums.Length; j++)
            {
                if(nums[j] != value)
                {
                    nums[i] = nums[j];
                    i++;
                }
            }
            return i;
        }

        public int RemoveElement_II(int[] nums, int value)
        {
            int i = 0;
            int n = nums.Length;
            while (i < n)
            {
                if (nums[i] == value)
                {
                    nums[i] = nums[n - 1];
                    n--;
                }
                else i++;
            }
            return i;
        }
    }