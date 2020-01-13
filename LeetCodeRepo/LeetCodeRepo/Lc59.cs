/*
below is accepted java solution, because c# doesn't support declare the following clause:
int[][] matrix = new int[n][n];
*/

namespace LeetCodeRepo{
    public class Lc59{
        public int[][] GenerateMatrix(int n){
            int[][] matrix = new int[n][n];
            if(n==0) return matrix;
            int r1 = 0, r2 = n-1, c1 = 0, c2 = n-1;
            int num =1;
            while(r1<=r2 && c1<=c2){
                for(int i = c1; i<=c2;i++) matrix[r1][i] = num++;
                r1++;
                for(int i = r1; i<=r2; i++) matrix[i][c2] = num++;
                c2--;
                for(int i = c2; i>=c1; i--) matrix[r2][i] = num++;
                r2--;
                for(int i = r2; i>=r1; i--) matrix[i][c1] = num++;
                c1++;
            }
            return matrix;
        }
    }
}