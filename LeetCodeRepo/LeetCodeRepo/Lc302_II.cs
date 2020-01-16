namespace LeetCodeRepo{
    public class Lc302_II{
        private int top, bottom, left, right;
        public int MinArea(char[][] image, int x, int y){
            if(image.Length == 0 || image[0].Length == 0) return 0;
            top = bottom = x;
            left = right = y;
            dfs(image, x, y);
            return (right -left) * (bottom - top);
        }

        private void dfs(char[][] image, int x, int y){
            if(x<0 || y<0 || x>=image.Length || y>= image[0].Length || image[x][y] == '0') return;
            image[x][y] = '0';
            top = Math.Min(top, x);
            bottom = Math.Max(bottom, x+1);
            left = Math.Min(left, y);
            right = Math.Max(right, y+1);
            dfs(image, x+1, y);
            dfs(image, x-1, y);
            dfs(image, x, y-1);
            dfs(image, x, y+1);
        }
    }
}