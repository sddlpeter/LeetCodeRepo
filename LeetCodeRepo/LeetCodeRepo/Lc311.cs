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
                        }
                    }
                }
            }
            return C;
        }
    }
}