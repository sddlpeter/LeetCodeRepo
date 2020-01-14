namespace LeetCodeRepo
{
    public class Lc240
    {
        public bool SearchMatrix(int[,] matrix, int target)
        {
            for(int i = 0; i<matrix.GetLength(0); i++){
                for(int j = 0; j<matrix.GetLength(1); j++){
                    if(matrix[i,j] == target) return true;
                }
            }
            return false;
        }
    }
}