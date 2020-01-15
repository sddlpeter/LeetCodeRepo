namespace LeetCodeRepo{
    public class Lc296_III{
        private List<int> collectRows(int[][] grid){
            List<int> rows = new List<int>();
            for(int row = 0; row<grid.Length; row++){
                for(int col = 0; col<grid[0].Length; col++){
                    if(grid[row][col] == 1) rows.Add(row);
                }
            }
            return rows;
        }

        private List<int> collectCols(int[][] grid){
            List<int> cols = new List<int>();
            for(int col = 0; col<grid[0].Length; col++){
                for(int row = 0; row<grid.Length; row++){
                    if(grid[row][col] ==1) cols.Add(col);
                }
            }
            return cols;
        }

        private int minDistance1D(List<int> points, int origin){
            int distance = 0;
            foreach(var point in points){
                distance += Math.Abs(point - origin);
            }
            return distance;
        }

        public int MinTotalDistance(int[][] grid){
            List<int> rows = collectRows(grid);
            List<int> cols = collectCols(grid);
            int row = rows[rows.Count/2];
            int col = cols[cols.Count/2];
            return minDistance1D(rows, row) + minDistance1D(cols, col);
        }
    }
}