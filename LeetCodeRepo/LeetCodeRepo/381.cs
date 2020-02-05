using System.Collections.Generic;
using System;

namespace LeetCodeRepo
{
    public class RandomizedCollection
    {
        List<int> lst;
        Dictionary<int, HashSet<int>> idx;
        Random rand = new Random();
        public RandomizedCollection()
        {
            lst = new List<int>();
            idx = new Dictionary<int, HashSet<int>>();
        }

        public bool Insert(int val)
        {
            if (!idx.ContainsKey(val)) idx[val] = new HashSet<int>();
            idx[val].Add(lst.Count);
            lst.Add(val);
            return idx[val].Count == 1;
        }

        public bool Remove(int val)
        {
            if (!idx.ContainsKey(val) || idx[val].Count == 0) return false;
            int remove_idx = idx[val].Count;
            idx[val].Remove(remove_idx);
            int last = lst[lst.Count - 1];
            lst[remove_idx] = last;
            idx[last].Add(remove_idx);
            idx[last].Remove(lst.Count - 1);
            lst.RemoveAt(lst.Count - 1);
            return true;
        }

        public int GetRandom()
        {
            return lst[rand.Next(lst.Count)];
        }
    }
}