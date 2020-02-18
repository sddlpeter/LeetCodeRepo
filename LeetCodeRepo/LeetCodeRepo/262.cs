    public class _262
    {
        public bool ValidTree(int n, int[][] edges)
        {
            int[] nums = new int[n];
            for(int i= 0; i<nums.Length; i++)
            {
                nums[i] = -1;
            }

            for(int i = 0; i<edges.Length; i++)
            {
                int x = find(nums, edges[i][0]);
                int y = find(nums, edges[i][1]);
                if (x == y) return false;
                nums[x] = y;
            }
            return edges.Length == n - 1;
        }

        public int find(int[] nums, int i)
        {
            if (nums[i] == -1) return i;
            return find(nums, nums[i]);
        }
    }