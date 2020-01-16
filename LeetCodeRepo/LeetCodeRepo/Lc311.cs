<<<<<<< HEAD
namespace LeetCodeRepo{
    public class Lc311{
        public int[][] multiply(int[][] A, int[][] B){
            int m = A.Length, n = A[0].Length, nB = B[0].Length;
            int[,] C = new int[m, nB];

            for(int i = 0; i<m; i++){
                for(int k = 0; k<n; k++){
                    if(A[i][k]!=0){
                        for(int j = 0; j<nB; j++){
                            if(B[k][j]!=0) C[i,j] = A[i][k] * B[k][j];
=======
/*
    below code is java
*/

namespace LeetCodeRepo
{
    public class Lc311
    {
        public int[][] multiply(int[][] A, int[][] B)
        {
            int m = A.length, n = A[0].length, nB = B[0].length;
            int[][] C = new int[m][nB];
            for (int i = 0; i < m; i++)
            {
                for (int k = 0; k < n; k++)
                {
                    if (A[i][k] != 0)
                    {
                        for (int j = 0; j < nB; j++)
                        {
                            if (B[k][j] != 0) C[i][j] += A[i][k] * B[k][j];
>>>>>>> ee23b8611f12ebb985acee6c0a21d61be40533f2
                        }
                    }
                }
            }
<<<<<<< HEAD
=======

>>>>>>> ee23b8611f12ebb985acee6c0a21d61be40533f2
            return C;
        }
    }
}