using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc349{
        public int[] Intersection(int[] nums1, int[] nums2){
            HashSet<int> set1 = new HashSet<int>();
            foreach(int i in nums1) set1.Add(i);
            HashSet<int> set2 = new HashSet<int>();
            foreach(int i in nums2) set2.Add(i);
            if(set1.Count < set2.Count) return set_intersection(set1, set2);
            else return set_intersection(set2, set1);
        }

        public int[] set_intersection(HashSet<int> set1, HashSet<int> set2){
            int[] output = new int[set1.Count];
            int idx = 0;
            foreach(int s in set1)
                if(set2.Contains(s)) output[idx++] = s;
            return output;
        }
    }
}