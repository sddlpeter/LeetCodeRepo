namespace LeetCodeRepo
{
    public class Lc218
    {
        public IList<IList<int>> GetSkyline(int[][] buildings)
        {
            var height = new List<IList<int>>();
            for (int i = 0; i < buildings.Length; i++)
            {
                height.Add(new int[] { buildings[i][0], -buildings[i][2] });
                height.Add(new int[] { buildings[i][1], buildings[i][2] });
            }
            height.Sort((a, b) =>
            {
                if (a[0] != b[0]) return a[0].CompareTo(b[0]);
                return a[1].CompareTo(b[1]);
            });
            var result = new List<IList<int>>();
            var sd = new SortedDictionary<int, int>(Comparer<int>.Create((a, b) => -a.CompareTo(b)));
            sd.Add(0, 0);
            var pre = 0;
            foreach (var h in height)
            {
                if (h[1] < 0)
                {
                    if (!sd.ContainsKey(-h[1])) sd[-h[1]] = 0;
                    sd[-h[1]]++;
                }
                else
                {
                    sd[h[1]]--;
                    if (sd[h[1]] <= 0) sd.Remove(h[1]);
                }
                int curr = sd.First().Key;
                if (pre != curr)
                {
                    result.Add(new int[] { h[0], curr });
                    pre = curr;
                }
            }
            return result;
        }
    }
}