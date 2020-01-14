namespace LeetCodeRepo
{
    public class Lc240
    {
        public bool SearchMatrix(int[,] matrix, int target)
        {
            if (matrix == null || matrix.GetLength(0) == 0) return false;
            int shortDim = Math.Min(matrix.GetLength(0), matrix.GetLength(1));
            for (int i = 0; i < shortDim; i++)
            {
                bool verticalFound = BinarySearch(matrix, target, i, true);
                bool HorizontalFound = BinarySearch(matrix, target, i, false);
                if (verticalFound || HorizontalFound) return true;
            }
            return false;
        }

        public bool BinarySearch(int[,] matrix, int target, int start, bool vertical)
        {
            int lo = start;
            int hi = vertical ? matrix.GetLength(1) - 1 : matrix.GetLength(0) - 1;
            while (hi >= lo)
            {
                int mid = (hi + lo) / 2;
                if (vertical)
                {
                    if (matrix[start, mid] < target)
                    {
                        lo = mid + 1;
                    }
                    else if (matrix[start, mid] > target)
                    {
                        hi = mid - 1;
                    }
                    else return true;
                }
                else
                {
                    if (matrix[mid, start] < target)
                    {
                        lo = mid + 1;
                    }
                    else if (matrix[mid, start] > target)
                    {
                        hi = mid - 1;
                    }
                    else return true;
                }
            }
            return false;
        }
    }
}