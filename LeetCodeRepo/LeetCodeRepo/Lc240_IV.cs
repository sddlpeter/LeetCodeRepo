namespace LeetCodeRepo{
    public class Lc240_IV{
        public bool SearchMatrix(int[,] matrix, int target){
            int row = matrix.GetLength(0) -1, col = 0;
            while(row >=0 && col < matrix.GetLength(1)){
                if(matrix[row,col]>target) row--;
                else if(matrix[row,col] <target) col++;
                else return true;
            }
            return false;
        }
    }
}