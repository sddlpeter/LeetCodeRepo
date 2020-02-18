    public class _323
    {
        public int CountComponents(int n, int[][] edges)
        {
            int[] roots = new int[n];
            for(int i = 0; i<n; i++)
            {
                roots[i] = i;
            }

            foreach(int[] e in edges)
            {
                int root1 = find(roots, e[0]);
                int root2 = find(roots, e[1]);
                if (root1 != root2)
                {
                    roots[root1] = root2;
                    n--;
                }
            }
            return n;
        }

        public int find(int[] roots, int id)
        {
            while(roots[id] != id)
            {
                roots[id] = roots[roots[id]];
                id = roots[id];
            }
            return id;
        }
    }