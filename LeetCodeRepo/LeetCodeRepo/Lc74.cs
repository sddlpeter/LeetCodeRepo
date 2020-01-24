namespace LeetCodeRepo
{
    public class Lc74
    {
        public bool SearchMatrix(int[][] matrix, int target)
        {
            int m = matrix.Length;
            if (m == 0) return false;
            int n = matrix[0].Length;
            int left = 0, right = m * n - 1;
            int pivotIdx, pivotElement;
            while (left <= right)
            {
                pivotIdx = (left + right) / 2;
                pivotElement = matrix[pivotIdx / n][pivotIdx % n];
                if (target == pivotElement) return true;
                else if (target < pivotElement) right = pivotIdx - 1;
                else left = pivotIdx + 1;
            }
            return false;
        }
    }
}