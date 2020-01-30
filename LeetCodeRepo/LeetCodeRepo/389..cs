namespace LeetCodeRepo
{
    public class _389
    {
        public char FindTheDifference(string s, string t)
        {
            int c = 0;
            for (int i = 0; i < s.Length; i++)
            {
                c ^= s[i];
            }
            for (int i = 0; i < t.Length; i++)
            {
                c ^= t[i];
            }
            return (char)c;
        }
    }
}