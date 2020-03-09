using System.Collections.Generic;
using System;
public class TwoSum_III
{
    Dictionary<int, bool> dict = new Dictionary<int, bool>();
    int max = int.MinValue;
    int min = int.MaxValue;

    public TwoSum_III()
    {

    }

    public void Add(int number)
    {
        dict[number] = dict.ContainsKey(number);
        max = Math.Max(max, number);
        min = Math.Min(min, number);
    }

    public bool Find(int value)
    {
        if (value < min + min || value > max + max) return false;
        foreach (int i in dict.Keys)
        {
            int j = value - i;
            if (dict.ContainsKey(j) && (i != j || dict[j] == true)) return true;
        }

        return false;
    }
}