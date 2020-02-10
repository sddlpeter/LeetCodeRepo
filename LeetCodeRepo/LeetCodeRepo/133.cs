using System.Collections.Generic;
using System;

    public class _133
    {
        private Dictionary<Node, Node> visited = new Dictionary<Node, Node>();

        public Node CloneGraph(Node node)
        {
            if (node == null) return node;
            if (visited.ContainsKey(node)) return visited[node];
            Node cloneNode = new Node(node.val, new List<Node>());
            visited[node] = cloneNode;
            foreach(Node neighbor in node.neighbors)
            {
                cloneNode.neighbors.Add(CloneGraph(neighbor));
            }
            return cloneNode;
        }
    }

    public class _133_II
    {
        public Node CloneGraph(Node node)
        {
            if (node == null) return node;
            Dictionary<Node, Node> visited = new Dictionary<Node, Node>();
            Queue<Node> queue = new Queue<Node>();
            queue.Enqueue(node);
            visited.Add(node, new Node(node.val, new List<Node>()));
            while (queue.Count > 0)
            {
                Node n = queue.Dequeue();
                foreach(Node neighbor in n.neighbors)
                {
                    if (!visited.ContainsKey(neighbor))
                    {
                        visited[neighbor] = new Node(neighbor.val, new List<Node>());
                        queue.Enqueue(neighbor);
                    }
                    visited[n].neighbors.Add(visited[neighbor]);
                }

            }
            return visited[node];
        }
    }

    public class Node
    {
        public int val;
        public IList<Node> neighbors;
        public Node()
        {
            val = 0;
            neighbors = new List<Node>();
        }

        public Node(int _val)
        {
            val = _val;
            neighbors = new List<Node>();
        }

        public Node(int _val, List<Node> _neighbors)
        {
            val = _val;
            neighbors = _neighbors;
        }
    }