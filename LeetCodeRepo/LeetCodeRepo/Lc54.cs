/*
dr and dr are the arrays to control traversal the matrix
{0, 1} means to move right
{1, 0} means to move down
{0, -1} means to move left
{-1, 0} means to move up

we should also make sure the current position is not beyond boundary
therefore, we have cr>=0 and cr<R, cc>=0 and cc<C
in addition, we cannot re-traversal the traversed position
we have seen array to keep in memory
*/

namespace LeetCodeRepo{
    public class Lc54{
        public IList<int> SpiralOrder(int[][] matrix){
            List<int> ans = new List<int>();
            if(matrix.Length == 0) return ans;
            int R = matrix.Length, C = matrix[0].Length;
            bool[,] seen = new bool[R,C];
            int[] dr = {0, 1, 0, -1};
            int[] dc = {1, 0, -1, 0};
            int r = 0, c = 0, di = 0;
            for(int i = 0; i<R*C; i++){
                ans.Add(matrix[r][c]);
                seen[r,c] = true;
                int cr = r + dr[di];
                int cc = c + dc[di];
                if(0<=cr && cr < R && 0<=cc && cc<C && !seen[cr,cc]){
                    r = cr;
                    c = cc;
                } else{
                    di = (di+1)%4;
                    r += dr[di];
                    c += dc[di];
                }
            }
            return ans;
        }
    }
}