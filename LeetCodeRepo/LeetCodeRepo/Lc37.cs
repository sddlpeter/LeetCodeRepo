/* the following solution passed all the test cases on leetcode,
but cannot be submitted, however, it actually works!

following is the test case:
            char[][] board = new char[][]
            {
                new char[]{'.', '.', '9', '7', '4', '8', '.', '.', '.'},
                new char[]{'7', '.', '.', '.', '.', '.', '.', '.', '.'},
                new char[]{'.', '2', '.', '1', '.', '9', '.', '.', '.'},
                new char[]{'.', '.', '7', '.', '.', '.', '2', '4', '.'},
                new char[]{'.', '6', '4', '.', '1', '.', '5', '9', '.'},
                new char[]{'.', '9', '8', '.', '.', '.', '3', '.', '.'},
                new char[]{'.', '.', '.', '8', '.', '3', '.', '2', '.'},
                new char[]{'.', '.', '.', '.', '.', '.', '.', '.', '6'},
                new char[]{'.', '.', '.', '2', '7', '5', '9', '.', '.'}
            };


*/

namespace LeetCodeRepo{
public class Lc37
    {
        public static int n = 3;
        public static int N = n * n;
        public static int[,] rows = new int[N, N + 1];
        public static int[,] cols = new int[N, N + 1];
        public static int[,] boxes = new int[N, N + 1];

        public static char[][] board;
        public static bool sudokuSolved = false;
        public bool couldPlace(int d, int row, int col)
        {
            int idx = (row / n) * n + col / n;
            return rows[row, d] + cols[col, d] + boxes[idx, d] == 0;
        }

        public void placeNumber(int d, int row, int col)
        {
            int idx = (row / n) * n + col / n;
            rows[row, d]++;
            cols[col, d]++;
            boxes[idx, d]++;
            board[row][col] = (char)(d + '0');
        }

        public void removeNumber(int d, int row, int col)
        {
            int idx = (row / n) * n + col / n;
            rows[row, d]--;
            cols[col, d]--;
            boxes[idx, d]--;
            board[row][col] = '.';
        }

        public void placeNextNumbers(int row, int col)
        {
            if ((col == N - 1) && (row == N - 1)) sudokuSolved = true;
            else
            {
                if (col == N - 1) backtrack(row + 1, 0);
                else backtrack(row, col + 1);
            }
        }

        public void backtrack(int row, int col)
        {
            if (board[row][col] == '.')
            {
                for (int d = 1; d < 10; d++)
                {
                    if (couldPlace(d, row, col))
                    {
                        placeNumber(d, row, col);
                        placeNextNumbers(row, col);
                        if (!sudokuSolved) removeNumber(d, row, col);
                    }
                }
            }
            else placeNextNumbers(row, col);
        }

        public void SolveSudoku(char[][] board)
        {
            Lc37.board = board;
            for (int i = 0; i < N; i++)
            {
                for (int j = 0; j < N; j++)
                {
                    char num = board[i][j];
                    if (num != '.')
                    {
                        int d = num - '0';
                        placeNumber(d, i, j);
                    }
                }
            }
            backtrack(0, 0);
        }
    }
}