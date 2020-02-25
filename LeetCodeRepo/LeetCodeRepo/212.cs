
using System.Collections.Generic;
public class Solution {
        public List<string> FindWords(char[][] board, string[] words)
        {
            List<string> res = new List<string>();
            TrieNode root = buildTrie(words);
            for(int i = 0; i<board.Length; i++)
            {
                for(int j = 0; j<board[0].Length; j++)
                {
                    dfs(board, i, j, root, res);
                }
            }
            return res;
        }

        public TrieNode buildTrie(string[] words)
        {
            TrieNode root = new TrieNode();
            foreach(string w in words)
            {
                TrieNode p = root;
                foreach(char c in w)
                {
                    int i = c - 'a';
                    if (p.next[i] == null) p.next[i] = new TrieNode();
                    p = p.next[i];
                }
                p.word = w;
            }
            return root;
        }

        public void dfs(char[][] board, int i, int j, TrieNode p, List<string> res)
        {
            char c = board[i][j];
            if (c == '#' || p.next[c - 'a'] == null) return;
            p = p.next[c - 'a'];
            if(p.word != null)
            {
                res.Add(p.word);
                p.word = null;
            }

            board[i][j] = '#';
            if (i > 0) dfs(board, i - 1, j, p, res);
            if (j > 0) dfs(board, i, j - 1, p, res);
            if (i < board.Length - 1) dfs(board, i + 1, j, p, res);
            if (j < board[0].Length - 1) dfs(board, i, j + 1, p, res);
            board[i][j] = c;
        }

        public class TrieNode
        {
            public TrieNode[] next = new TrieNode[26];
            public string word;
        }
}