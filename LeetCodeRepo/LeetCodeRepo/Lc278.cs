namespace LeetCodeRepo{
    public class Lc278{
        public int FirstBadVersion(int n){
            for(int i = 1; i<n; i++){
                if(IsBadVersion(i)) return i;
            }
            return n;
        }

        public int FirstBadVersion2(int n){
            int l = 1, r = n;
            while(l<r){
                int mid = l + (r-l)/2;
                if(IsBadVersion(mid)) r = mid;
                else l = mid+1;
            }
            return l;
        }

        private bool IsBadVersion(int version){
            return true;
        }
    }
}