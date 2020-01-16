/*

Input:
[
  ["5","3",".",".","7",".",".",".","."],
  ["6",".",".","1","9","5",".",".","."],
  [".","9","8",".",".",".",".","6","."],
  ["8",".",".",".","6",".",".",".","3"],
  ["4",".",".","8",".","3",".",".","1"],
  ["7",".",".",".","2",".",".",".","6"],
  [".","6",".",".",".",".","2","8","."],
  [".",".",".","4","1","9",".",".","5"],
  [".",".",".",".","8",".",".","7","9"]
]
Output: true

*/

using System.Collections.Generic;

namespace LeetCodeRepo{
    public class Lc36{
        public bool IsValidSudoku(char[][] board){
            for(int i = 0; i<9; i++){
                HashSet<char> rows = new HashSet<char>();
                HashSet<char> cols = new HashSet<char>();
                HashSet<char> boxes = new HashSet<char>();
                for(int j = 0; j<9; j++){
                    if(board[i][j] != '.' && rows.Contains(board[i][j])) return false;
                    rows.Add(board[i][j]);
                    if(board[j][i] != '.' && cols.Contains(board[j][i])) return false;
                    cols.Add(board[j][i]);
                    int row = 3*(i/3);
                    int col = 3*(i%3);
                    if(board[row+j/3][col + j%3] != '.' && boxes.Contains(board[row+j/3][col + j%3])) return false;
                    boxes.Add(board[row+j/3][col + j%3]);

                }
            }
            return true;
        }
    }
}