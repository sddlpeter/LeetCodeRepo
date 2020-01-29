using System.Collections.Generic;

namespace LeetCodeRepo
{

    public class _126
    {
        public IList<IList<string>> FindLadders(string beginWord, string endWord, List<string> wordList)
        {
            List<IList<string>> ans = new List<IList<string>>();
            List<string> temp = new List<string>();
            temp.Add(beginWord);
            findLaddersHelper(beginWord, endWord, wordList, temp, ans);
            return ans;
        }
        int min = int.MaxValue;

        private void findLaddersHelper(string beginWord, string endWord, List<string> wordList, List<string> temp,
            List<IList<string>> ans)
        {
            if (beginWord.Equals(endWord))
            {
                if (min > temp.Count)
                {
                    ans.Clear();
                    min = temp.Count;
                    ans.Add(new List<string>(temp));
                }
                else if (min == temp.Count)
                {
                    ans.Add(new List<string>(temp));
                }
                return;
            }
            if (temp.Count >= min) return;
            for (int i = 0; i < wordList.Count; i++)
            {
                string curWord = wordList[i];
                if (temp.Contains(curWord)) continue;
                if (oneChanged(beginWord, curWord))
                {
                    temp.Add(curWord);
                    findLaddersHelper(curWord, endWord, wordList, temp, ans);
                    temp.RemoveAt(temp.Count - 1);
                }
            }
        }

        private bool oneChanged(string beginWord, string curWord)
        {
            int count = 0;
            for (int i = 0; i < beginWord.Length; i++)
            {
                if (beginWord[i] != curWord[i]) count++;
                if (count == 2) return false;
            }
            return count == 1;
        }
    }

    public class _126_II
    {
        int min = int.MaxValue;
        public List<IList<string>> FindLadders(string beginWord, string endWord, List<string> wordList)
        {
            List<IList<string>> ans = new List<IList<string>>();
            List<string> temp = new List<string>();
            temp.Add(beginWord);
            findLaddersHelper(beginWord, endWord, wordList, temp, ans);
            return ans;
        }

        public void findLaddersHelper(string beginWord, string endWord, List<string> wordList,
            List<string> temp, List<IList<string>> ans)
        {
            if (beginWord.Equals(endWord))
            {
                if (min > temp.Count)
                {
                    ans.Clear();
                    min = temp.Count;
                    ans.Add(new List<string>(temp));
                }
                else if (min == temp.Count)
                {
                    ans.Add(new List<string>(temp));
                }
                return;
            }
            if (temp.Count > min) return;
            HashSet<string> dict = new HashSet<string>(wordList);
            List<string> neighbors = getNeighbors(beginWord, dict);
            foreach (var neighbor in neighbors)
            {
                if (temp.Contains(neighbor)) continue;
                temp.Add(neighbor);
                findLaddersHelper(neighbor, endWord, wordList, temp, ans);
                temp.RemoveAt(temp.Count - 1);
            }
        }

        private List<string> getNeighbors(string node, HashSet<string> dict)
        {
            List<string> res = new List<string>();
            char[] chs = node.ToCharArray();
            for (char ch = 'a'; ch <= 'z'; ch++)
            {
                for (int i = 0; i < chs.Length; i++)
                {
                    if (chs[i] == ch) continue;
                    char old_ch = chs[i];
                    chs[i] = ch;
                    if (dict.Contains(new string(chs)))
                    {
                        res.Add(new string(chs));
                    }
                    chs[i] = old_ch;
                }
            }
            return res;
        }
    }

    public class _126_III
    {
        int min = 0;
        public List<IList<string>> FindLadders(string beginWord, string endWord, List<string> wordList)
        {
            List<IList<string>> ans = new List<IList<string>>();
            if (!wordList.Contains(endWord)) return ans;
            Dictionary<string, List<string>> map = bfs(beginWord, endWord, wordList);
            List<string> temp = new List<string>();
            temp.Add(beginWord);
            findLaddersHelper(beginWord, endWord, map, temp, ans);
            return ans;
        }

        private void findLaddersHelper(string beginWord, string endWord, Dictionary<string, List<string>> map,
            List<string> temp, List<IList<string>> ans)
        {
            if (beginWord.Equals(endWord))
            {
                ans.Add(new List<string>(temp));
                return;
            }
            if (temp.Count - 1 == min) return;
            List<string> neighbors = map.ContainsKey(beginWord) ? map[beginWord] : new List<string>();
            foreach (var neighbor in neighbors)
            {
                if (temp.Contains(neighbor)) continue;
                temp.Add(neighbor);
                findLaddersHelper(neighbor, endWord, map, temp, ans);
                temp.RemoveAt(temp.Count - 1);
            }
        }

        public Dictionary<string, List<string>> bfs(string beginWord, string endWord, List<string> wordList)
        {
            Queue<string> queue = new Queue<string>();
            queue.Enqueue(beginWord);
            Dictionary<string, List<string>> map = new Dictionary<string, List<string>>();
            bool isFound = false;

            HashSet<string> dict = new HashSet<string>(wordList);
            while (queue.Count > 0)
            {
                int size = queue.Count;
                min++;
                for (int j = 0; j < size; j++)
                {
                    string temp = queue.Dequeue();
                    List<string> neighbors = getNeighbors(temp, dict);
                    map[temp] = neighbors;
                    foreach (var neighbor in neighbors)
                    {
                        if (neighbor.Equals(endWord)) isFound = true;
                        queue.Enqueue(neighbor);
                    }
                }
                if (isFound) break;
            }
            return map;
        }

        private List<string> getNeighbors(string node, HashSet<string> dict)
        {
            List<string> res = new List<string>();
            char[] chs = node.ToCharArray();
            for (char ch = 'a'; ch <= 'z'; ch++)
            {
                for (int i = 0; i < chs.Length; i++)
                {
                    if (chs[i] == ch) continue;
                    char old_ch = chs[i];
                    chs[i] = ch;
                    if (dict.Contains(new string(chs))) res.Add(new string(chs));
                    chs[i] = old_ch;
                }
            }
            return res;
        }
    }

    public class _126_IV
    {
        public List<IList<string>> FindLadders(string beginWord, string endWord, List<string> wordList)
        {
            List<IList<string>> ans = new List<IList<string>>();
            if (!wordList.Contains(endWord)) return ans;
            Dictionary<string, int> distance = new Dictionary<string, int>();
            Dictionary<string, List<string>> map = new Dictionary<string, List<string>>();
            bfs(beginWord, endWord, wordList, map, distance);
            List<string> temp = new List<string>();
            temp.Add(beginWord);
            findLaddersHelper(beginWord, endWord, map, distance, temp, ans);
            return ans;
        }

        private void findLaddersHelper(string beginWord, string endWord, Dictionary<string, List<string>> map,
            Dictionary<string, int> distance, List<string> temp, List<IList<string>> ans)
        {
            if (beginWord.Equals(endWord))
            {
                ans.Add(new List<string>(temp));
                return;
            }
            List<string> neighbors = map.ContainsKey(beginWord) ? map[beginWord] : new List<string>();
            foreach (var neighbor in neighbors)
            {
                if (distance[beginWord] + 1 == distance[neighbor])
                {
                    temp.Add(neighbor);
                    findLaddersHelper(neighbor, endWord, map, distance, temp, ans);
                    temp.RemoveAt(temp.Count - 1);
                }
            }
        }

        public void bfs(string beginWord, string endWord, List<string> wordList, Dictionary<string, List<string>> map,
            Dictionary<string, int> distance)
        {
            Queue<string> queue = new Queue<string>();
            queue.Enqueue(beginWord);
            distance[beginWord] = 0;
            bool isFound = false;
            int depth = 0;
            HashSet<string> dict = new HashSet<string>(wordList);
            while (queue.Count > 0)
            {
                int size = queue.Count;
                depth++;
                for (int j = 0; j < size; j++)
                {
                    string temp = queue.Dequeue();
                    List<string> neighbors = getNeighbors(temp, dict);
                    map[temp] = neighbors;
                    foreach (var neighbor in neighbors)
                    {
                        if (!distance.ContainsKey(neighbor))
                        {
                            distance[neighbor] = depth;
                            if (neighbor.Equals(endWord)) isFound = true;
                            queue.Enqueue(neighbor);
                        }
                    }
                }
                if (isFound) break;
            }
        }

        public List<string> getNeighbors(string node, HashSet<string> dict)
        {
            List<string> res = new List<string>();
            char[] chs = node.ToCharArray();
            for (char ch = 'a'; ch <= 'z'; ch++)
            {
                for (int i = 0; i < chs.Length; i++)
                {
                    if (chs[i] == ch) continue;
                    char old_ch = chs[i];
                    chs[i] = ch;
                    if (dict.Contains(new string(chs))) res.Add(new string(chs));
                    chs[i] = old_ch;
                }
            }
            return res;
        }
    }
}