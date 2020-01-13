using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lc48
{
    class Program
    {
        static void Main(string[] args)
        {
            int[][] matrix = new int[][]
            {
                new int[]{ 1, 2, 3 }, new int[]{4, 5, 6}, new int[]{7, 8,9}
            };

            var s = new Solution3();
            s.printMatrix(matrix);
            s.Rotate(matrix);
            s.printMatrix(matrix);


        }
    }

    public class Solution
    {
        public void Rotate(int[][] matrix)
        {
            int n = matrix.Length;
            for(int i = 0; i<n; i++)
            {
                for(int j = i; j<n; j++)
                {
                    int temp = matrix[i][j];
                    matrix[i][j] = matrix[j][i];
                    matrix[j][i] = temp;
                }
            }

            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n / 2; j++)
                {
                    int temp = matrix[i][j];
                    matrix[i][j] = matrix[i][n - j - 1];
                    matrix[i][n - j - 1] = temp;
                }
            }
        }

        public void printMatrix(int[][] matrix)
        {
            foreach(var nums in matrix)
            {
                foreach(var i in nums)
                {
                    Console.Write(i + " ");
                }
                Console.WriteLine();
            }
            Console.WriteLine();
        }
    }


    public class Solution2
    {
        public void Rotate(int[][] matrix)
        {
            int n = matrix.Length;
            for(int i= 0; i<n/2 + n%2; i++)
            {
                for(int j = 0; j<n/2; j++)
                {
                    int[] store = new int[4];
                    int row = i;
                    int col = j;
                    for(int k = 0; k<4; k++)
                    {
                        store[k] = matrix[row][col];
                        int temp = row;
                        row = col;
                        col = n - 1 - temp;
                    }

                    for(int k = 0; k<4; k++)
                    {
                        matrix[row][col] = store[(k + 3) % 4];
                        int temp = row;
                        row = col;
                        col = n - 1 - temp;
                    }
                }
            }
        }

        public void printMatrix(int[][] matrix)
        {
            foreach (var nums in matrix)
            {
                foreach (var i in nums)
                {
                    Console.Write(i + " ");
                }
                Console.WriteLine();
            }
            Console.WriteLine();
        }
    }

    public class Solution3
    {
        public void Rotate(int[][] matrix)
        {
            int n = matrix.Length; //n = 3
            for (int i = 0; i < (n + 1) / 2; i++) //i = 0, 1
            {
                for (int j = 0; j < n / 2; j++) //j = 0
                {
                    int temp = matrix[n - j - 1][i];//matrix[2][0]
                    matrix[n - j - 1][i] = matrix[n - i - 1][n - j - 1];//matrix[2][0] = matrix[2][2]
                    matrix[n - i - 1][n - j - 1] = matrix[j][n - i - 1];//matrix[2][2] = matrix[0][2]
                    matrix[j][n - i - 1] = matrix[i][j];//matrix[0][2] = matrix[0][0]
                    matrix[i][j] = temp; //matrix[0][0] = matrix[2][0]
                }
            }
        }

        public void printMatrix(int[][] matrix)
        {
            foreach (var nums in matrix)
            {
                foreach (var i in nums)
                {
                    Console.Write(i + " ");
                }
                Console.WriteLine();
            }
            Console.WriteLine();
        }
    }
}
