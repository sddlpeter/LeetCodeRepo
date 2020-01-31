using System.Collections.Generic;
namespace LeetCodeRepo
{

    public class _207_BFS
    {
        public bool CanFinish(int numCourses, int[][] prerequisites)
        {
            int[,] matrix = new int[numCourses, numCourses];
            int[] serialNumbers = new int[numCourses];

            for (int i = 0; i < prerequisites.Length; i++)
            {
                int curr = prerequisites[i][0];
                int pre = prerequisites[i][1];
                if (matrix[curr, pre] == 0)
                    serialNumbers[curr]++;
                matrix[curr, pre] = 1;
            }

            Queue<int> queue = new Queue<int>();
            for (int i = 0; i < serialNumbers.Length; i++)
            {
                if (serialNumbers[i] == 0) queue.Enqueue(i);
            }
            int count = 0;
            while (queue.Count > 0)
            {
                int course = queue.Dequeue();
                count++;
                for (int i = 0; i < numCourses; i++)
                {
                    if (matrix[i, course] != 0)
                    {
                        if (--serialNumbers[i] == 0)
                        {
                            queue.Enqueue(i);
                        }
                    }
                }
            }
            return count == numCourses;
        }
    }


    public class _207
    {
        public bool CanFinish(int numCourses, int[][] prerequisites)
        {
            int[,] matrix = new int[numCourses, numCourses];
            int[] indegree = new int[numCourses];

            for (int i = 0; i < prerequisites.Length; i++)
            {
                int ready = prerequisites[i][0];
                int pre = prerequisites[i][1];
                if (matrix[pre, ready] == 0) indegree[ready]++;
                matrix[pre, ready] = 1;
            }
            int count = 0;
            Queue<int> queue = new Queue<int>();
            for (int i = 0; i < indegree.Length; i++)
            {
                if (indegree[i] == 0) queue.Enqueue(i);
            }
            while (queue.Count > 0)
            {
                int course = queue.Dequeue();
                count++;
                for (int i = 0; i < numCourses; i++)
                {
                    if (matrix[course, i] != 0)
                    {
                        if (--indegree[i] == 0) queue.Enqueue(i);
                    }
                }
            }
            return count == numCourses;
        }
    }
}