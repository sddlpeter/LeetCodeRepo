namespace LeetCodeRepo
{
    public class NestedIterator
    {
        Stack<Pos> stack = new Stack<Pos>();
        Pos curr = null;

        public NestedIterator(IList<NestedInteger> nestedList)
        {
            curr = NextInteger(new Pos(nestedList, -1)); // little trick starting at -1
        }

        public bool HasNext()
        {
            return curr.index < curr.list.Count;
        }

        public int Next()
        {
            int x = HasNext() ? curr.list[curr.index].GetInteger() : -1;
            curr = NextInteger(curr);
            return x;
        }

        public Pos NextInteger(Pos p)
        {
            p.index++;

            while (p.index < p.list.Count || stack.Count > 0)
            {
                if (p.index < p.list.Count)
                {
                    if (p.list[p.index].IsInteger()) break;

                    if (p.index + 1 < p.list.Count)
                        stack.Push(new Pos(p.list, p.index + 1));

                    p = new Pos(p.list[p.index].GetList(), 0);
                }
                else
                {
                    p = stack.Pop();
                }
            }

            return p;
        }
    }

    // tuple to hold list and index
    public class Pos
    {
        public IList<NestedInteger> list;
        public int index;

        public Pos(IList<NestedInteger> list, int index)
        {
            this.list = list;
            this.index = index;
        }
    }
}