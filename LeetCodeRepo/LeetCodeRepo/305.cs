using System.Collections.Generic;

public class _305_BruteForce {
        public IList<int> NumIslands2(int m, int n, int[][] positions)
        {
            List<int> ans = new List<int>();
            char[,] grid = new char[m, n];
            for(int i = 0; i<m; i++)
            {
                for(int j = 0; j<n; j++)
                {
                    grid[i,j] = '0';
                }
            }

            foreach(var pos in positions)
            {
                grid[pos[0], pos[1]] = '1';
                ans.Add(numIslands(grid));
            }
            return ans;
        }

        public int numIslands(char[,] grid)
        {
            if (grid == null || grid.Length == 0) return 0;
            int nr = grid.GetLength(0);
            int nc = grid.GetLength(1);

            bool[,] visited = new bool[nr, nc];
            for(int i = 0; i<nr; i++)
            {
                for(int j = 0; j<nc; j++)
                {
                    visited[i, j] = false;
                }
            }

            int num_islands = 0;
            for(int r = 0; r<nr; r++)
            {
                for(int c = 0; c<nc; c++)
                {
                    if(grid[r,c] == '1' && !visited[r, c])
                    {
                        num_islands++;
                        dfs(grid, r, c, visited);
                    }
                }
            }
            return num_islands;
        }

        public void dfs(char[,] grid, int r, int c, bool[,] visited)
        {
            int nr = grid.GetLength(0);
            int nc = grid.GetLength(1);

            if (r < 0 || c < 0 || r >= nr || c >= nc || grid[r, c] == '0' || visited[r, c]) return;
            visited[r, c] = true;
            dfs(grid, r - 1, c, visited);
            dfs(grid, r + 1, c, visited);
            dfs(grid, r, c - 1, visited);
            dfs(grid, r, c + 1, visited);
        }
}

    public class _305_UnionFind
    {
        int[][] dirs = new int[][]
        {
            new int[]{0, 1 }, new int[]{1, 0 }, new int[]{-1, 0 }, new int[]{0, -1}
        };
        public List<int> NumIslands2(int m, int n, int[][] positions)
        {
            List<int> result = new List<int>();
            if (m <= 0 || n <= 0) return result;
            int count = 0;
            int[] roots = new int[m * n];
            for(int i = 0; i<roots.Length; i++)
            {
                roots[i] = -1;
            }
            foreach(var p in positions)
            {
                int root = n * p[0] + p[1];
                roots[root] = root;
                count++;
                foreach(var dir in dirs)
                {
                    int x = p[0] + dir[0];
                    int y = p[1] + dir[1];
                    int nb = n * x + y;
                    if (x < 0 || x >= m || y < 0 || y >= n || roots[nb] == -1) continue;
                    int rootNb = findIsland(roots, nb);
                    if(root!= rootNb)
                    {
                        roots[root] = rootNb;
                        root = rootNb;
                        count--;
                    }
                }

                result.Add(count);
            }
            return result;
        }

        public int findIsland(int[] roots, int id)
        {
            while (id != roots[id]) id = roots[id];
            return id;
        }
    }
