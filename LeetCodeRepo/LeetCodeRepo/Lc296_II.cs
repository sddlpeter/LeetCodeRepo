namespace LeetCodeRepo
{
    public class Solution
    {
        public int MinTotalDistance(int[][] grid)
        {
            List<int> rows = new List<int>();
            List<int> cols = new List<int>();
            for (int row = 0; row < grid.Length; row++)
            {
                for (int col = 0; col < grid[0].Length; col++)
                {
                    if (grid[row][col] == 1)
                    {
                        rows.Add(row);
                        cols.Add(col);
                    }
                }
            }
            int r = rows[rows.Count / 2];
            Array.Sort(cols.ToArray());
            int c = cols[cols.Count / 2];
            return minDistance1D(rows, r) + minDistance1D(cols, c);
        }

        public int minDistance1D(List<int> points, int origin)
        {
            int distance = 0;
            foreach (var point in points)
            {
                distance += Math.Abs(point - origin);
            }
            return distance;
        }

    }
}