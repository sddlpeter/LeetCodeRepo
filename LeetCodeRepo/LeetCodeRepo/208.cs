
public class Trie
{
    private TrieNode root;
    public Trie()
    {
        root = new TrieNode();
        root.val = ' ';
    }

    public void Insert(string word)
    {
        TrieNode ws = root;
        for (int i = 0; i < word.Length; i++)
        {
            char c = word[i];
            if (ws.children[c - 'a'] == null)
            {
                ws.children[c - 'a'] = new TrieNode();
            }
            ws = ws.children[c - 'a'];
        }
        ws.isWord = true;
    }

    public bool Search(string word)
    {
        TrieNode ws = root;
        for (int i = 0; i < word.Length; i++)
        {
            char c = word[i];
            if (ws.children[c - 'a'] == null) return false;
            ws = ws.children[c - 'a'];
        }
        return ws.isWord;
    }

    public bool StartsWith(string prefix)
    {
        TrieNode ws = root;
        for (int i = 0; i < prefix.Length; i++)
        {
            char c = prefix[i];
            if (ws.children[c - 'a'] == null) return false;
            ws = ws.children[c - 'a'];
        }
        return true;
    }
}


public class TrieNode
{
    public char val;
    public bool isWord;
    public TrieNode[] children = new TrieNode[26];
    public TrieNode()
    {
    }

    TrieNode(char c)
    {
        TrieNode node = new TrieNode();
        node.val = c;
    }

}

/**
 * Your Trie object will be instantiated and called as such:
 * Trie obj = new Trie();
 * obj.Insert(word);
 * bool param_2 = obj.Search(word);
 * bool param_3 = obj.StartsWith(prefix);
 */
