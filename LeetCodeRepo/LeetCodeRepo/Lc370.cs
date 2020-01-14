namespace LeetCodeRepo
{
    public class Lc370
    {
        public int[] GetModifiedArray(int length, int[][] updates)
        {
            int[] res = new int[length];
            foreach(var update in updates){
                int val = update[2];
                int start = update[0];
                int end = update[1];
                res[start]+=val;
                if(end<length-1) res[end+1]-=val;
            }
            int sum = 0;
            for(int i = 0;i<length; i++){
                sum+=res[i];
                res[i] = sum;
            }
            return res;
        }
    }
}