/*
    Input: [[1,0,2,0,1],[0,0,0,0,0],[0,0,1,0,0]]

    1 - 0 - 2 - 0 - 1
    |   |   |   |   |
    0 - 0 - 0 - 0 - 0
    |   |   |   |   |
    0 - 0 - 1 - 0 - 0

    Output: 7 

    Explanation: Given three buildings at (0,0), (0,4), (2,2), and an obstacle at (0,2),
                the point (1,2) is an ideal empty land to build a house, as the total 
                travel distance of 3+3+1=7 is minimal. So return 7.
*/


namespace LeetCodeRepo{
    public class Lc317{
        public int[] delta = new int[]{0, 1, 0, -1, 0};
        public int min = int.MaxValue;
        public int ShortestDistance(int[][] grid){
            int[,] dist = new int[grid.Length,grid[0].Length];
            int start = 1;
            for(int i = 0; i<grid.Length; i++){
                for(int j = 0; j<grid[0].Length; j++){
                    if(grid[i][j] == 1){
                        bfsVisit(grid, dist, i, j, --start);
                    }
                }
            }
            return min == int.MaxValue ? -1 : min;
        }

        public void bfsVisit(int[][] grid, int[,] dist, int row, int col, int start){
            Queue<int[]> q = new Queue<int[]>();
            q.Enqueue(new int[]{row, col});
            int level = 0;
            min = int.MaxValue;
            while(q.Count>0){
                int size = q.Count;
                level++;
                for(int k = 0; k<size; k++){
                    int[] node = q.Dequeue();
                    for(int i = 1; i<delta.Length; i++){
                        int newRow = node[0] + delta[i-1];
                        int newCol = node[1] + delta[i];
                        if(newRow >= 0 && newRow < grid.Length && 
                        newCol>=0 && newCol < grid[0].Length && grid[newRow][newCol] == start){
                            q.Enqueue(new int[]{newRow, newCol});
                            dist[newRow,newCol] += level;
                            min = Math.Min(min, dist[newRow,newCol]);
                            grid[newRow][newCol]--;
                        }
                    }
                }
            }
        }
    }
}