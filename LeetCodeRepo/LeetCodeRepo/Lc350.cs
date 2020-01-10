using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc350{
        public int[] Intersect(int[] nums1, int nums2){
            if(nums1.Length>nums2.Length) return Intersect(nums2, nums1);
            Dictionary<int, int> set1 = new Dictionary<int, int>();
            foreach(int i in nums1){
                if(set1.ContainsKey(i)) set1[i]++;
                else set1[x] = 1;
            }
            List<int> ans = new List<int>();
            foreach(int i in nums2){
                if(set1.ContainsKey(i) && set1[i]>=1) {
                    ans.Add(i);
                    set1[i]--;
                }
            }
            return ans.ToArray();
        }
    }
}