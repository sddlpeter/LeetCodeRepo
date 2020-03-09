using System.Collections.Generic;

public class ValidWordAbbr
{

    private string[] dict;
    public ValidWordAbbr(string[] dictionary)
    {
        this.dict = dictionary;
    }

    public bool IsUnique(string word)
    {
        int n = word.Length;
        foreach (string s in dict)
        {
            if (word.Equals(s))
            {
                continue;
            }
            int m = s.Length;
            if (m == n && s[0] == word[0] && s[m - 1] == word[m - 1]) return false;
        }
        return true;
    }
}

public class ValidWordAbbr_II
{
    private Dictionary<string, HashSet<string>> abbrDict = new Dictionary<string, HashSet<string>>();

    public ValidWordAbbr_II(string[] dictionary)
    {
        foreach (string s in dictionary)
        {
            string abbr = ToAbbr(s);
            HashSet<string> words = abbrDict.ContainsKey(abbr) ? abbrDict[abbr] : new HashSet<string>();
            words.Add(s);
            abbrDict[abbr] = words;
        }
    }

    public bool IsUnique(string word)
    {
        string abbr = ToAbbr(word);
        HashSet<string> words = abbrDict.ContainsKey(abbr) ? abbrDict[abbr] : null;
        return words == null || (words.Count == 1 && words.Contains(word));
    }

    private string ToAbbr(string s)
    {
        int n = s.Length;
        if (n <= 2) return s;
        return s[0] + (n - 2).ToString() + s[n - 1];
    }
}
