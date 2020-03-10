public class NumArray
{
    private int[] data;

    public NumArray(int[] nums)
    {
        data = nums;
    }

    public int sumRange(int i, int j)
    {
        int sum = 0;
        for (int k = i; k <= j; k++)
        {
            sum += data[k];
        }

        return sum;
    }
}

public class NumArray_II
{
    private int[] sum;

    public NumArray_II(int[] nums)
    {
        sum = new int[nums.Length + 1];
        for (int i = 0; i < nums.Length; i++)
        {
            sum[i + 1] = sum[i] + nums[i];
        }
    }

    public int SumRange(int i, int j)
    {
        return sum[j + 1] - sum[i];
    }
}