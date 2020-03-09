using System;
public class TicTacToe
{
    private int[] rows;
    private int[] cols;
    private int diagonal;
    private int antiDiagonal;

    public TicTacToe(int n)
    {
        rows = new int[n];
        cols = new int[n];
    }

    public int move(int row, int col, int player)
    {
        int toAdd = player == 1 ? 1 : -1;
        rows[row] += toAdd;
        cols[col] += toAdd;
        if (row == col)
        {
            diagonal += toAdd;
        }

        if (col == (cols.Length - row - 1))
        {
            antiDiagonal += toAdd;
        }
        int size = rows.Length;
        if (Math.Abs(rows[row]) == size || Math.Abs(cols[col]) == size || Math.Abs(diagonal) == size || Math.Abs(antiDiagonal) == size) return player;
        return 0;
    }
}