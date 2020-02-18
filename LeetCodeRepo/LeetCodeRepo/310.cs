using System.Collections.Generic;
using System.Linq;

public class _310 {
    public IList<int> FindMinHeightTrees(int n, int[][] edges) {
            if (n == 1) return new List<int> { 0 };
            if (n < 2 || edges == null || edges.Length == 0 || edges[0].Length == 0) return new List<int>();
            var dic = new Dictionary<int, List<int>>();
            for(int i = 0; i<edges.GetLength(0); i++)
            {
                if (!dic.ContainsKey(edges[i][0]))
                {
                    dic.Add(edges[i][0], new List<int>());
                }
                dic[edges[i][0]].Add(edges[i][1]);
                if (!dic.ContainsKey(edges[i][1]))
                {
                    dic.Add(edges[i][1], new List<int>());
                }
                dic[edges[i][1]].Add(edges[i][0]);
            }
            var leaf = new Queue<int>(dic.Where(d => d.Value.Count == 1).Select(item => item.Key));
            while (dic.Count > 2)
            {
                var nl = new Queue<int>();
                while (leaf.Any())
                {
                    var node = leaf.Dequeue();
                    var temp = dic[node][0];
                    dic.Remove(node);
                    dic[temp].Remove(node);
                    if (dic[temp].Count == 1) nl.Enqueue(temp);
                }
                leaf = nl;
            }
            return leaf.ToList();
    }
}