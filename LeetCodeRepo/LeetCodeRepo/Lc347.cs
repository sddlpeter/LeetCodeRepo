using System.Collections.Generic;
namespace LeetCodeRepo
{
    public class Lc347
    {
        public IList<int> TopKFrequent(int[] nums, int k)
        {
            List<int>[] bucket = new List<int>[nums.Length + 1];
            Dictionary<int, int> dict = new Dictionary<int, int>();
            foreach (var n in nums)
            {
                if (dict.ContainsKey(n)) dict[n]++;
                else dict[n] = 1;
            }
            foreach (var i in dict.Keys)
            {
                int count = dict[i];
                if (bucket[count] == null)
                {
                    bucket[count] = new List<int>();
                }
                bucket[count].Add(i);
            }

            List<int> res = new List<int>();
            for (int pos = bucket.Length - 1; pos >= 0 && res.Count < k; pos--)
            {
                if (bucket[pos] != null)
                {
                    res.AddRange(bucket[pos]);
                }
            }
            return res;
        }

        public void print(IList<int> nums)
        {
            foreach (var i in nums)
            {
                Console.Write(i + " ");
            }
            Console.WriteLine();
        }
    }
}