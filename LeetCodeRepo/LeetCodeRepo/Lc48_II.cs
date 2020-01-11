/*
Given input matrix =
[
  [ 5, 1, 9,11],
  [ 2, 4, 8,10],
  [13, 3, 6, 7],
  [15,14,12,16]
], 

rotate the input matrix in-place such that it becomes:
[
  [15,13, 2, 5],
  [14, 3, 4, 1],
  [12, 6, 8, 9],
  [16, 7,10,11]
]
*/

namespace LeetCodeRepo{
    public class Lc48_II{
        public void rotate(int[][] matrix){
            int n = matrix.Length;  //4
            for(int i = 0; i<n/2 + n%2; i++){
                for(int j = 0; j<n/2; j++){
                    int[] temp = new int[4];
                    int row = i;    //0
                    int col = j;    //0
                    for(int k = 0; k<4; k++){
                        temp[k] = matrix[row][col]; //[0][0] - [0][3] - [3][3] - [3][0]
                        int x= row; //0 - 0 - 3 - 3
                        row = col;  //0 - 3 - 3 - 0
                        col = n-1-x;    //3 - 3 - 0 - 0
                    }
                    for(int k = 0; k<4; k++){
                        matrix[row][col] = temp[(k+3)%4]; //[0][0] = temp[3]
                        int x= row; // x=0
                        row = col;  // row = 0
                        col = n-1-x;    // col = 3
                    }
                }
            }
        }
    }
}