public class NumMatrix {
    int[][] m;
    int[][] summat;
    public NumMatrix(int[][] matrix) {
        if(matrix.Length==0||matrix[0].Length==0)return;
        summat=new int[matrix.Length+1][];
        for(int i=0;i<summat.Length;i++)
            summat[i]=new int[matrix[0].Length+1];
        for(int i=0;i<matrix.Length;i++)
        {
            for(int j=0;j<matrix[0].Length;j++)
            {
                summat[i+1][j+1]=summat[i+1][j]+summat[i][j+1]+matrix[i][j]-summat[i][j];
            }
        }
        m=matrix;
    }
    
    public void Update(int row, int col, int val) {
        int offset=val-m[row][col];
        if(offset!=0)
        {
            for(int i=row+1;i<summat.Length;i++)
            {
                for(int j=col+1;j<summat[0].Length;j++)
                    summat[i][j]+=offset;
            }
        }
        m[row][col]=val;
    }
    
    public int SumRegion(int row1, int col1, int row2, int col2) {
        if(summat==null)return 0;
        return summat[row2+1][col2+1]-summat[row2+1][col1]-summat[row1][col2+1]+summat[row1][col1];
    }
}