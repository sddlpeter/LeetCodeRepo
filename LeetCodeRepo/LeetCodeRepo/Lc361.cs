/*
    Input: [["0","E","0","0"],["E","0","W","E"],["0","E","0","0"]]
    Output: 3 
    Explanation: For the given grid,

    0 E 0 0 
    E 0 W E 
    0 E 0 0

    Placing a bomb at (1,1) kills 3 enemies.
*/
namespace LeetCodeRepo{
    public class Lc361{
        public int MaxKilledEnemies(char[][] grid){
            int m = grid.Length;
            int n = m != 0? grid[0].Length : 0;
            int result = 0;
            int rowhits = 0;
            int[] colhits = new int[n];
            for(int i = 0; i<m; i++){
                for(int j = 0; j<n; j++){
                    if(j==0 || grid[i][j-1] == 'W'){
                        rowhits = 0;
                        for(int k = j; k<n && grid[i][k] != 'W'; k++){
                            rowhits += grid[i][k] == 'E' ? 1 :0;
                        }
                    }
                    if(i== 0 || grid[i-1][j] == 'W'){
                        colhits[j] = 0;
                        for(int k = i; k<m && grid[k][j] != 'W'; k++){
                            colhits[j] += grid[k][j] == 'E' ? 1: 0;
                        }
                    }
                    if(grid[i][j] == '0')
                        result = Math.Max(result, rowhits + colhits[j]);
                }
            }
            return result;
        }
    }
}