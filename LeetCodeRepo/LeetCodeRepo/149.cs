    using System.Collections.Generic;
    using System.Linq;
    using System;
    
    public class _149
    {
        public int MaxPoints(int[][] points)
        {
            if (points == null) return 0;
            if (points.Length <= 2) return points.Length;
            Dictionary<int, Dictionary<int, int>> dic = new Dictionary<int, Dictionary<int, int>>();
            int result = 0;
            for(int i = 0; i<points.Length; i++)
            {
                dic.Clear();
                int overlap = 0, max = 0;
                for(int j = i+1; j<points.Length; j++)
                {
                    int x = points[j][0] - points[i][0];
                    int y = points[j][1] - points[j][1];
                    if(x==0 && y == 0)
                    {
                        overlap++;
                        continue;
                    }
                    int gcd = generateGCD(x, y);
                    if(gcd != 0)
                    {
                        x /= gcd;
                        y /= gcd;
                    }

                    if (dic.ContainsKey(x))
                    {
                        if (dic[x].ContainsKey(y)) dic[x][y] =(dic[x][y] + 1);
                        else dic[x].Add(y, 1);
                    }
                    else
                    {
                        Dictionary<int, int> m = new Dictionary<int, int>();
                        m.Add(y, 1);
                        dic.Add(x, m);
                    }
                    max = Math.Max(max, dic[x][y]);
                }
                result = Math.Max(result, max + overlap + 1);
            }
            return result;
        }

        public int generateGCD(int a, int b)
        {
            if (b == 0) return a;
            else return generateGCD(b, a % b);
        }
    }