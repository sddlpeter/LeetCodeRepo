namespace LeetCodeRepo
{
    public class Lc296
    {
        public int MinTotalDistance(int[][] grid)
        {
            int minDistance = int.MaxValue;
            for (int row = 0; row < grid.Length; row++)
            {
                for (int col = 0; col < grid[0].Length; col++)
                {
                    int distance = search(grid, row, col);
                    minDistance = Math.Min(distance, minDistance);
                }
            }
            return minDistance;
        }

        private int search(int[][] grid, int row, int col)
        {
            Queue<Point> q = new Queue<Point>();
            int m = grid.Length;
            int n = grid[0].Length;
            bool[,] visited = new bool[m, n];
            q.Enqueue(new Point(row, col, 0));
            int totalDistance = 0;
            while (q.Count > 0)
            {
                Point point = q.Dequeue();
                int r = point.row;
                int c = point.col;
                int d = point.distance;
                if (r < 0 || c < 0 || r >= m || c >= n || visited[r, c]) continue;
                if (grid[r][c] == 1) totalDistance += d;
                visited[r, c] = true;
                q.Enqueue(new Point(r + 1, c, d + 1));
                q.Enqueue(new Point(r - 1, c, d + 1));
                q.Enqueue(new Point(r, c + 1, d + 1));
                q.Enqueue(new Point(r, c - 1, d + 1));
            }
            return totalDistance;
        }
        public class Point
        {
            public int row;
            public int col;
            public int distance;
            public Point(int row, int col, int distance)
            {
                this.row = row;
                this.col = col;
                this.distance = distance;
            }
        }
    }
}