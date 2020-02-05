using System.Collections.Generic;
using System;
namespace LeetCodeRepo
{
    public class RandomizedSet
    {
        Dictionary<int, int> dict;
        List<int> list;
        Random rand = new Random();

        public RandomizedSet()
        {
            dict = new Dictionary<int, int>();
            list = new List<int>();
        }

        public bool Insert(int val)
        {
            if (dict.ContainsKey(val)) return false;
            dict[val] = list.Count;
            list.Add(val);
            return true;
        }

        public bool Remove(int val)
        {
            if (!dict.ContainsKey(val)) return false;
            int lastElement = list[list.Count - 1];
            int idx = dict[val];
            list[idx] = lastElement;
            dict[lastElement] = idx;
            list.RemoveAt(list.Count - 1);
            dict.Remove(val);
            return true;
        }

        public int GetRandom()
        {
            return list[rand.Next(list.Count)];
        }
    }
}