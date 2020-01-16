namespace LeetCodeRepo{
    public class Lc302_III{
        public int MinArea(char[][] image, int x, int y){
            int m = image.Length, n = image[0].Length;
            int left = searchColumns(image, 0, y, 0, m, true);
            int right = searchColumns(image, y+1, n, 0, m, false);
            int top = searchRows(image, 0, x, left, right, true);
            int bottom = searchRows(image, x+1, m, left, right, false);
            return (right -left) * (bottom -top);
        }

        private int searchColumns(char[][] image, int i, int j, int top, int bottom, bool WhiteToBlack){
            while(i!=j){
                int k = top, mid = (i+j)/2;
                while(k<bottom && image[k][mid] == '0') k++;
                if(k<bottom == WhiteToBlack) j = mid;
                else i = mid+1;
            }
            return i;
        }

        private int searchRows(char[][] image, int i, int j, int left, int right, bool WhiteToBlack){
            while(i!=j){
                int k = left, mid = (i+j)/2;
                while(k<right && image[mid][k] == '0') k++;
                if(k<right == WhiteToBlack) j = mid;
                else i = mid+1;
            }
            return i;
        }
    }
}