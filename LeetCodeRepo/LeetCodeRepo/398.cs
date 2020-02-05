using System.Collections.Generic;
using System;

namespace LeetCodeRepo
{
    public class _398
    {
        int[] nums;
        Random rand;

        public _398(int[] nums)
        {
            this.nums = nums;
            this.rand = new Random();
        }

        public int Pick(int target)
        {
            int result = -1;
            int count = 0;
            for (int i = 0; i < nums.Length; i++)
            {
                if (nums[i] != target) continue;
                if (rand.Next(++count) == 0) result = i;
            }
            return result;
        }
    }
}