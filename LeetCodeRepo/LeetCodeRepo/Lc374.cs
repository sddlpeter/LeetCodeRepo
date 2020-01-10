namespace LeetCodeRepo{
    public class Lc374{
        public int guessNumber(int n){
            int low = 1, high = n;
            while(low<=high){
                int mid = low + (high-low)/2;
                int res = guess(mid);
                if(res == 0) return mid;
                else if(res<0) high = mid-1;
                else low = mid+1;
            }
            return -1;
        }

        private int guess(int num){
            return 0;
        }
    }
}