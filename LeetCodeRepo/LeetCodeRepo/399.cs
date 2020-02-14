    public class _399
    {
        public double[] CalcEquation(IList<IList<string>> eq, double[] vals, IList<IList<string>> q)
        {
            Dictionary<string, Dictionary<string, double>> m = new Dictionary<string, Dictionary<string, double>>();
            for (int i = 0; i < vals.Length; i++)
            {
                if (!m.ContainsKey(eq[i][0])) m[eq[i][0]] = new Dictionary<string, double>();
                if (!m.ContainsKey(eq[i][1])) m[eq[i][1]] = new Dictionary<string, double>();
                m[eq[i][0]].Add(eq[i][1], vals[i]);
                m[eq[i][1]].Add(eq[i][0], 1 / vals[i]);
            }
            double[] r = new double[q.Count];
            for(int i = 0; i<q.Count; i++)
            {
                r[i] = dfs(q[i][0], q[i][1], 1, m, new HashSet<string>());
            }
            return r;
        }

        public double dfs(string s, string t, double r, Dictionary<string, Dictionary<string, double>> m, HashSet<string> seen)
        {
            if (!m.ContainsKey(s) || !seen.Add(s)) return -1;
            if (s.Equals(t)) return r;
            Dictionary<string, double> next = m[s];
            foreach(var c in next.Keys)
            {
                double result = dfs(c, t, r * next[c], m, seen);
                if (result != -1) return result;
            }
            return -1;
        }
    }