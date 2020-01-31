using System.Collections.Generic;

namespace LeetCodeRepo
{
    public class _210
    {
        int white = 1;
        int gray = 2;
        int balck = 3;

        bool isPossible;
        Dictionary<int, int> color;
        Dictionary<int, List<int>> adjList;
        List<int> topologicalOrder;

        public int[] FindOrder(int numCourses, int[][] prerequisites)
        {
            this.init(numCourses);
            for (int i = 0; i < prerequisites.Length; i++)
            {
                int curr = prerequisites[i][0];
                int prev = prerequisites[i][1];
                List<int> lst = adjList.ContainsKey(prev) ? adjList[prev] : new List<int>();
                lst.Add(curr);
                adjList[prev] = lst;
            }

            for (int i = 0; i < numCourses; i++)
            {
                if (this.color[i] == white)
                {
                    this.dfs(i);
                }
            }
            int[] order;
            if (this.isPossible)
            {
                order = new int[numCourses];
                for (int i = 0; i < numCourses; i++)
                {
                    order[i] = this.topologicalOrder[numCourses - i - 1];
                }
            }
            else
            {
                order = new int[0];
            }
            return order;

        }

        public void init(int numCourses)
        {
            this.isPossible = true;
            this.color = new Dictionary<int, int>();
            this.adjList = new Dictionary<int, List<int>>();
            this.topologicalOrder = new List<int>();

            for (int i = 0; i < numCourses; i++)
            {
                this.color[i] = white;
            }
        }

        public void dfs(int node)
        {
            if (!this.isPossible) return;
            this.color[node] = gray;
            foreach (var neighbor in this.adjList.ContainsKey(node) ? adjList[node] : new List<int>())
            {
                if (this.color[neighbor] == white)
                {
                    this.dfs(neighbor);

                }
                else if (this.color[neighbor] == gray)
                {
                    this.isPossible = false;
                }
            }
            this.color[node] = balck;
            this.topologicalOrder.Add(node);
        }
    }
}