
using System.Collections.Generic;
namespace LeetCodeRepo
{
    public class _127
    {
        public int LadderLength(string beginWord, string endWord, HashSet<string> wordDict)
        {
            HashSet<string> dict = new HashSet<string>(wordDict), vis = new HashSet<string>();
            Queue<string> q = new Queue<string>();
            q.Enqueue(beginWord);
            for (int len = 1; q.Count > 0; len++)
            {
                for (int i = q.Count; i > 0; i--)
                {
                    string w = q.Dequeue();
                    if (w.Equals(endWord)) return len;
                    for (int j = 0; j < w.Length; j++)
                    {
                        char[] ch = w.ToCharArray();
                        for (char c = 'a'; c <= 'z'; c++)
                        {
                            if (c == w[j]) continue;
                            ch[j] = c;
                            string nb = new string(ch);
                            if (dict.Contains(nb) && vis.Add(nb)) q.Enqueue(nb);
                        }
                    }
                }
            }
            return 0;
        }
    }
}