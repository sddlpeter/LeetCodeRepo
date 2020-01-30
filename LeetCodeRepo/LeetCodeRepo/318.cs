namespace LeetCodeRepo
{
    public class _318
    {
        public int MaxProduct(string[] words)
        {
            if (words == null || words.Length == 0) return 0;
            int len = words.Length;
            int[] value = new int[len];
            for (int i = 0; i < len; i++)
            {
                string temp = words[i];
                value[i] = 0;
                for (int j = 0; j < temp.Length; j++)
                {
                    value[i] |= 1 << (temp[j] - 'a');
                }
            }
            int maxProduct = 0;
            for (int i = 0; i < len; i++)
            {
                for (int j = i + 1; j < len; j++)
                {
                    if ((value[i] & value[j]) == 0 && (words[i].Length * words[j].Length > maxProduct))
                        maxProduct = words[i].Length * words[j].Length;
                }
            }
            return maxProduct;
        }
    }
}