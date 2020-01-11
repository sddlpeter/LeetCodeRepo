/*

    // initial
    1, 2, 3
    4, 5, 6
    7, 8, 9

    // exchange matrix[i][j] with matrix[j][i]
    1, 4, 7
    2, 5, 8
    3, 6, 9

    // reverse each row
    7, 4, 1
    8, 5, 2
    9, 6, 3


*/


//solution 1: transpose then reverse
namespace LeetCodeRepo{
    public class Lc48{
        public void Rotate(int[][] matrix){
            int n = matrix.Length;

            //transpose matrix
            for(int i = 0; i<n; i++){
                for(int j = i; j<n; j++){
                    int temp = matrix[j][i];
                    matrix[j][i] = matrix[i][j];
                    matrix[i][j] = temp;
                }
            }
            //reverse each row
            for(int i = 0; i<n; i++){
                for(int j = 0; j<n/2; j++){
                    int temp = matrix[i][j];
                    matrix[i][j] = matrix[i][n-j-1];
                    matrix[i][n-j-1] = temp;
                }
            }
        }
    }
}