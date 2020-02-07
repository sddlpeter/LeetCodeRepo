using System.Collections.Generic;
using System.Linq;
using System;

namespace LeetCodeRepo
{
    public class RandomizedCollection
    {
        Random random = new Random();
        Dictionary<int, HashSet<int>> dict = new Dictionary<int, HashSet<int>>();
        IList<int> numList = new List<int>();
        public RandomizedCollection()
        {

        }

        public bool Insert(int val)
        {
            if (dict.ContainsKey(val))
            {
                numList.Add(val);
                dict[val].Add(numList.Count - 1);
                return false;
            }
            else
            {
                numList.Add(val);
                dict[val] = new HashSet<int>() { numList.Count - 1 };
                return true;
            }
        }

        public bool Remove(int val)
        {
            if (!dict.ContainsKey(val)) return false;
            var curIndex = dict[val].First();
            dict[val].Remove(curIndex);
            if (!dict[val].Any()) dict.Remove(val);
            if (curIndex == numList.Count - 1)
            {
                numList.RemoveAt(numList.Count - 1);
            }
            else
            {
                var needToModify = numList[numList.Count - 1];
                numList[curIndex] = needToModify;
                numList.RemoveAt(numList.Count - 1);

                dict[needToModify].Remove(numList.Count);
                dict[needToModify].Add(curIndex);
            }
            return true;
        }

        public int GetRandom()
        {
            var randomIndex = random.Next(numList.Count);
            return numList[randomIndex];
        }
    }
}