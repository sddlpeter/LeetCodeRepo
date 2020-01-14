namespace LeetCodeRepo{
    public class Lc240_III{
        private int[,] matrix;
        private int target;
        public bool SearchMatrix(int[,] matrix_in, int target_in){
            matrix = matrix_in;
            target = target_in;
            if(matrix == null || matrix.Length == 0) return false;
            return searchRec(0, 0, matrix.GetLength(1)-1, matrix.GetLength(0)-1);
        }

        private bool searchRec(int left, int up, int right, int down){
            if(left>right || up>down) return false;
            else if(target < matrix[up,left] || target > matrix[down,right]) return false;
            int row = up;
            int mid = left + (right - left)/2;
            while(row <= down && matrix[row,mid] <= target){
                if(matrix[row,mid] == target) return true;
                row++;
            }

            return searchRec(left, row, mid-1, down) || searchRec(mid+1, up, right, row-1);
        }
    }
}