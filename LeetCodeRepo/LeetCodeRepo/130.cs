/*

Example:

X X X X
X O O X
X X O X
X O X X
After running your function, the board should be:

X X X X
X X X X
X X X X
X O X X

*/


namespace LeetcodeRepo
{
    public class _130
    {
        public void Solve(char[][] board)
        {
            if (board.Length == 0 || board[0].Length == 0) return;
            if (board.Length < 2 || board[0].Length < 2) return;
            int m = board.Length, n = board[0].Length;
            for (int i = 0; i < m; i++)
            {
                if (board[i][0] == 'O') boundaryDFS(board, i, 0);
                if (board[i][n - 1] == 'O') boundaryDFS(board, i, n - 1);
            }

            for (int j = 0; j < n; j++)
            {
                if (board[0][j] == 'O') boundaryDFS(board, 0, j);
                if (board[m - 1][j] == 'O') boundaryDFS(board, m - 1, j);
            }

            for (int i = 0; i < m; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    if (board[i][j] == 'O') board[i][j] = 'X';
                    else if (board[i][j] == '*') board[i][j] = 'O';
                }
            }
        }

        private void boundaryDFS(char[][] board, int i, int j)
        {
            if (i < 0 || i > board.Length - 1 || j < 0 || j > board[0].Length - 1) return;
            if (board[i][j] == 'O') board[i][j] = '*';
            if (i > 1 && board[i - 1][j] == 'O') boundaryDFS(board, i - 1, j);
            if (i < board.Length - 2 && board[i + 1][j] == 'O') boundaryDFS(board, i + 1, j);
            if (j > 1 && board[i][j - 1] == 'O') boundaryDFS(board, i, j - 1);
            if (j < board[i].Length - 2 && board[i][j + 1] == 'O') boundaryDFS(board, i, j + 1);
        }
    }

    public class _130_DFS
    {
        public void Solve(char[][] board)
        {
            if (board.Length == 0 || board[0].Length == 0) return;
            if (board.Length < 3 || board[0].Length < 3) return;
            int m = board.Length;
            int n = board[0].Length;
            for (int i = 0; i < m; i++)
            {
                if (board[i][0] == 'O') helper(board, i, 0);
                if (board[i][n - 1] == 'O') helper(board, i, n - 1);
            }
            for (int j = 1; j < n - 1; j++)
            {
                if (board[0][j] == 'O') helper(board, 0, j);
                if (board[m - 1][j] == 'O') helper(board, m - 1, j);
            }
            for (int i = 0; i < m; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    if (board[i][j] == 'O') board[i][j] = 'X';
                    if (board[i][j] == '*') board[i][j] = 'O';
                }
            }
        }

        private void helper(char[][] board, int r, int c)
        {
            if (r < 0 || c < 0 || r > board.Length - 1 || c > board[0].Length - 1 || board[r][c] != 'O') return;
            board[r][c] = '*';
            helper(board, r + 1, c);
            helper(board, r - 1, c);
            helper(board, r, c + 1);
            helper(board, r, c - 1);
        }
    }

    public class _130_BFS
    {
        public void Solve(char[][] board)
        {
            if (board.Length == 0) return;
            int rowN = board.Length;
            int colN = board[0].Length;
            Queue<Point> queue = new Queue<Point>();
            for (int r = 0; r < rowN; r++)
            {
                if (board[r][0] == 'O')
                {
                    board[r][0] = '+';
                    queue.Enqueue(new Point(r, 0));
                }
                if (board[r][colN - 1] == 'O')
                {
                    board[r][colN - 1] = '+';
                    queue.Enqueue(new Point(r, colN - 1));
                }
            }

            for (int c = 0; c < colN; c++)
            {
                if (board[0][c] == 'O')
                {
                    board[0][c] = '+';
                    queue.Enqueue(new Point(0, c));
                }
                if (board[rowN - 1][c] == 'O')
                {
                    board[rowN - 1][c] = '+';
                    queue.Enqueue(new Point(rowN - 1, c));
                }
            }

            while (queue.Count > 0)
            {
                Point p = queue.Dequeue();
                int row = p.val1;
                int col = p.val2;
                if (row - 1 >= 0 && board[row - 1][col] == 'O')
                {
                    board[row - 1][col] = '+';
                    queue.Enqueue(new Point(row - 1, col));
                }
                if (row + 1 < rowN && board[row + 1][col] == 'O')
                {
                    board[row + 1][col] = '+';
                    queue.Enqueue(new Point(row + 1, col));
                }
                if (col - 1 >= 0 && board[row][col - 1] == 'O')
                {
                    board[row][col - 1] = '+';
                    queue.Enqueue(new Point(row, col - 1));
                }
                if (col + 1 < colN && board[row][col + 1] == 'O')
                {
                    board[row][col + 1] = '+';
                    queue.Enqueue(new Point(row, col + 1));
                }
            }

            for (int i = 0; i < rowN; i++)
            {
                for (int j = 0; j < colN; j++)
                {
                    if (board[i][j] == 'O') board[i][j] = 'X';
                    if (board[i][j] == '+') board[i][j] = 'O';
                }
            }
        }

        public class Point
        {
            public int val1;
            public int val2;
            public Point(int x, int y)
            {
                this.val1 = x;
                this.val2 = y;
            }
        }

    }
}