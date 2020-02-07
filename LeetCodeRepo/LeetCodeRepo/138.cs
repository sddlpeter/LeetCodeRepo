using System;
using System.Collections.Generic;

namespace LeetCodeRepo
{
    public class _138_I
    {
        Dictionary<Node, Node> visited = new Dictionary<Node, Node>();
        public Node CopyRandomList(Node head)
        {
            if (head == null) return null;
            if (this.visited.ContainsKey(head)) return this.visited[head];
            Node node = new Node(head.val);
            this.visited[head] = node;
            node.next = this.CopyRandomList(head.next);
            node.random = this.CopyRandomList(head.random);
            return node;
        }
    }

    public class _138_II
    {
        Dictionary<Node, Node> visited = new Dictionary<Node, Node>();
        public Node GetCloneNode(Node node)
        {
            if (node != null)
            {
                if (this.visited.ContainsKey(node))
                {
                    return this.visited[node];
                }
                else
                {
                    this.visited[node] = new Node(node.val);
                    return this.visited[node];
                }
            }
            return null;
        }

        public Node CopyRandomList(Node head)
        {
            if (head == null) return null;
            Node oldNode = head;
            Node newNode = new Node(oldNode.val);
            this.visited[oldNode] = newNode;
            while (oldNode != null)
            {
                newNode.random = this.GetCloneNode(oldNode.random);
                newNode.next = this.GetCloneNode(oldNode.next);
                oldNode = oldNode.next;
                newNode = newNode.next;
            }
            return this.visited[head];
        }
    }


    public class _138_III
    {
        public Node CopyRandomList(Node head)
        {
            if (head == null) return null;
            Node ptr = head;
            while (ptr != null)
            {
                Node newNode = new Node(ptr.val);
                newNode.next = ptr.next;
                ptr.next = newNode;
                ptr = newNode.next;
            }
            ptr = head;

            while (ptr != null)
            {
                ptr.next.random = (ptr.random != null) ? ptr.random.next : null;
                ptr = ptr.next.next;
            }

            Node ptr_old_list = head;
            Node ptr_new_list = head.next;
            Node head_old = head.next;
            while (ptr_old_list != null)
            {
                ptr_old_list.next = ptr_old_list.next.next;
                ptr_new_list.next = (ptr_new_list.next != null) ? ptr_new_list.next.next : null;
                ptr_old_list = ptr_old_list.next;
                ptr_new_list = ptr_new_list.next;
            }
            return head_old;
        }
    }

    public class Node
    {
        public int val;
        public Node next;
        public Node random;

        public Node(int _val)
        {
            val = _val;
            next = null;
            random = null;
        }
    }
}