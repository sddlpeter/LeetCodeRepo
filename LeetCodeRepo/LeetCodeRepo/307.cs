
public class NumArray
{
    private int[] nums;
    public NumArray(int[] nums)
    {
        this.nums = nums;

    }

    public void Update(int i, int val)
    {
        nums[i] = val;
    }

    public int SumRange(int i, int j)
    {
        int sum = 0;
        for (int l = i; l <= j; l++)
        {
            sum += nums[l];
        }
        return sum;
    }
}

public class NumArray_II
{
    int[] tree;
    int n;
    public NumArray_II(int[] nums)
    {
        if (nums.Length > 0)
        {
            n = nums.Length;
            tree = new int[n * 2];
            buildTree(nums);
        }
    }

    public void buildTree(int[] nums)
    {
        for (int i = n, j = 0; i < 2 * n; i++, j++)
        {
            tree[i] = nums[j];
        }
        for (int i = n - 1; i > 0; i--)
        {
            tree[i] = tree[i * 2] + tree[i * 2 + 1];
        }
    }

    public void Update(int pos, int val)
    {
        pos += n;
        tree[pos] = val;
        while (pos > 0)
        {
            int left = pos;
            int right = pos;
            if (pos % 2 == 0)
            {
                right = pos - 1;
            }
            else
            {
                left = pos - 1;
            }

            tree[pos / 2] = tree[left] + tree[right];
            pos /= 2;
        }
    }

    public int SumRange(int l, int r)
    {
        l += n;
        r += n;
        int sum = 0;
        while (l <= r)
        {
            if ((l % 2) == 1)
            {
                sum += tree[l];
                l++;
            }
            if (r % 2 == 0)
            {
                sum += tree[r];
                r--;
            }
            l /= 2;
            r /= 2;
        }
        return sum;
    }
}