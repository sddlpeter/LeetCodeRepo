namespace LeetCodeRepo
{
    public class _200_DFS
    {
        public int NumIslands(char[][] grid)
        {
            if (grid == null || grid.Length == 0) return 0;
            int nr = grid.Length;
            int nc = grid[0].Length;
            int num_islands = 0;
            for (int r = 0; r < nr; r++)
            {
                for (int c = 0; c < nc; c++)
                {
                    if (grid[r][c] == '1')
                    {
                        num_islands++;
                        Dfs(grid, r, c);
                    }
                }
            }
        }

        void Dfs(char[][] grid, int r, int c)
        {
            int nr = grid.Length;
            int nc = grid[0].Length;
            if (r < 0 || c < 0 || r >= nr || c >= nc || grid[r][c] == '0') return;
            grid[r][c] = '0';
            Dfs(grid, r - 1, c);
            Dfs(grid, r + 1, c);
            Dfs(grid, r, c - 1);
            Dfs(grid, r, c + 1);
        }
    }

    public class _200_BFS
    {
        public int NumIslands(char[][] grid)
        {
            if (grid == null || grid.Length == 0) return 0;
            int nr = grid.Length;
            int nc = grid[0].Length;
            int num_islands = 0;

            for (int r = 0; r < nr; r++)
            {
                for (int c = 0; c < nc; c++)
                {
                    if (grid[r][c] == '1')
                    {
                        num_islands++;
                        grid[r][c] = '0';
                        Queue<int> neighbors = new Queue<int>();
                        neighbors.Enqueue(r * nc + c);
                        while (neighbors.Count > 0)
                        {
                            int id = neighbors.Dequeue();
                            int row = id / nc;
                            int col = id % nc;
                            if (row - 1 >= 0 && grid[row - 1][col] == '1')
                            {
                                neighbors.Enqueue((row - 1) * nc + col);
                                grid[row - 1][col] = '0';
                            }
                            if (row + 1 < nr && grid[row + 1][col] == '1')
                            {
                                neighbors.Enqueue((row + 1) * nc + col);
                                grid[row + 1][col] = '0';
                            }
                            if (col - 1 >= 0 && grid[row][col - 1] == '1')
                            {
                                neighbors.Enqueue(row * nc + col - 1);
                                grid[row][col - 1] = '0';
                            }
                            if (col + 1 < nc && grid[row][col + 1] == '1')
                            {
                                neighbors.Enqueue(row * nc + col + 1);
                                grid[row][col + 1] = '0';
                            }
                        }
                    }
                }
            }
            return num_islands;
        }
    }
}