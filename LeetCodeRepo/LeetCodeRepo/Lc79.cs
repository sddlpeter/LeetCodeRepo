/*
    board =
    [
    ['A','B','C','E'],
    ['S','F','C','S'],
    ['A','D','E','E']
    ]

    Given word = "ABCCED", return true.
    Given word = "SEE", return true.
    Given word = "ABCB", return false.
*/


namespace LeetCodeRepo
{
    public class Lc79
    {

        static bool[,] visited;
        public bool Exist(char[][] board, string word)
        {
            visited = new bool[board.Length, board[0].Length];
            for (int i = 0; i < board.Length; i++)
            {
                for (int j = 0; j < board[i].Length; j++)
                {
                    if (word[0] == board[i][j] && search(board, word, i, j, 0))
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        public bool search(char[][] board, string word, int i, int j, int index)
        {
            if (index == word.Length) return true;
            if (i >= board.Length || i < 0 || j >= board[i].Length || j < 0 || board[i][j] != word[index] || visited[i, j]) return false;
            visited[i, j] = true;
            if (search(board, word, i - 1, j, index + 1) ||
            search(board, word, i + 1, j, index + 1) ||
            search(board, word, i, j - 1, index + 1) ||
            search(board, word, i, j + 1, index + 1)) return true;
            visited[i, j] = false;
            return false;
        }
    }
}

