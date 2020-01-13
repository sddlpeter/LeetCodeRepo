using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc73{
        public void setZeros(int[][] matrix){
            int R = matrix.Length, C = matrix[0].Length;
            HashSet<int> rows = new HashSet<int>();
            HashSet<int> cols = new HashSet<int>();

            for(int i = 0; i<R; i++){
                for(int j = 0; j<C; j++){
                    if(matrix[i][j] == 0){
                        cols.Add(i);
                        rows.Add(j);
                    }
                }
            }

            for(int i = 0; i<R; i++){
                for(int j = 0; j<C; j++){
                    if(rows.Contains(i) || cols.Contains(j)) matrix[i][j] = 0;
                }
            }
        }
    }
}