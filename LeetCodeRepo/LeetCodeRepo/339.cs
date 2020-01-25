using System.Collections.Generic;

namespace LeetCodeRepo
{
    public class _339
    {

        public int DepthSum(IList<NestedInteger> nestedList)
        {
            return DepthSum(nestedList, 1);
        }

        public int DepthSum(IList<NestedInteger> list, int depth)
        {
            int sum = 0;
            foreach (var n in list)
            {
                if (n.IsInteger())
                {
                    sum += n.GetInteger() * depth;
                }
                else
                {
                    sum += DepthSum(n.GetList(), depth + 1);
                }
            }
            return sum;
        }


    }

    public class NestedInteger
    {
        public bool IsInteger()
        {
            return true;
        }

        public int GetInteger()
        {
            return 0;
        }

        public IList<NestedInteger> GetList()
        {
            return new List<NestedInteger>();
        }
    }


}