namespace LeetCodeRepo{
    public class Lc350{
        public int[] Intersect(int[] nums1, int[] nums2){
            Array.Sort(nums1);
            Array.Sort(nums2);
            List<int> ans = new List<int>();
            int i = 0, j = 0;
            while(i<nums1.Length && j<nums2.Length){
                if(nums1[i] == nums2[j]){
                    ans.Add(nums1[i]);
                    i++;
                    j++;
                } else if(nums1[i] < nums2[j]) i++;
                else j++;
            }
            return ans.ToArray();
        }
    }
}