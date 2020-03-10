
public class NumMatrix
{
    private int[][] data;

    public NumMatrix(int[][] matrix)
    {
        data = matrix;
    }

    public int SumRegion(int row1, int col1, int row2, int col2)
    {
        int sum = 0;
        for (int r = row1; r <= row2; r++)
        {
            for (int c = col1; c <= col2; c++)
            {
                sum += data[r][c];
            }
        }
        return sum;
    }
}


public class NUmMatrix_II
{
    private int[,] dp;
    public NUmMatrix_II(int[][] matrix)
    {
        if (matrix.Length == 0 || matrix[0].Length == 0) return;
        dp = new int[matrix.Length + 1, matrix[0].Length + 1];
        for (int r = 0; r < matrix.Length; r++)
        {
            for (int c = 0; c < matrix[0].Length; c++)
            {
                dp[r + 1, c + 1] = dp[r + 1, c] + dp[r, c + 1] + matrix[r][c] - dp[r, c];
            }
        }
    }

    public int SumRegion(int row1, int col1, int row2, int col2)
    {
        return dp[row2 + 1, col2 + 1] - dp[row1, col2 + 1] - dp[row2 + 1, col1] + dp[row1, col1];
    }
}