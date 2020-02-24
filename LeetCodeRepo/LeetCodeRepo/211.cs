public class WordDictionary
{

    public class TrieNode
    {
        public TrieNode[] children = new TrieNode[26];
        public string item = "";
    }

    private TrieNode root = new TrieNode();
    public void AddWord(string word)
    {
        TrieNode node = root;
        foreach (var c in word.ToCharArray())
        {
            if (node.children[c - 'a'] == null)
            {
                node.children[c - 'a'] = new TrieNode();
            }
            node = node.children[c - 'a'];
        }
        node.item = word;
    }

    public bool Search(string word)
    {
        return match(word.ToCharArray(), 0, root);
    }

    private bool match(char[] chs, int k, TrieNode node)
    {
        if (k == chs.Length) return !node.item.Equals("");
        if (chs[k] != '.')
        {
            return node.children[chs[k] - 'a'] != null && match(chs, k + 1, node.children[chs[k] - 'a']);
        }
        else
        {
            for (int i = 0; i < node.children.Length; i++)
            {
                if (node.children[i] != null)
                {
                    if (match(chs, k + 1, node.children[i]))
                    {
                        return true;
                    }
                }
            }
        }
        return false;
    }
}
