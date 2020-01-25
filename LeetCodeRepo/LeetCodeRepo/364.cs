using System.Collections.Generic;

namespace LeetCodeRepo
{
    public class _364
    {
        public int DepthSumInverse(List<NestedInteger> nestedList)
        {
            int unweighted = 0, weighted = 0;
            while(nestedList.Count>0){
                List<NestedInteger> nextLevel = new List<NestedInteger>();
                foreach(var ni in nestedList){
                    if(ni.IsInteger()){
                        unweighted += ni.GetInteger();
                    } else{
                        nextLevel.AddRange(ni.GetList());
                    }
                }
                weighted += unweighted;
                nestedList = nextLevel;
            }
            return weighted;
        }

        public class NestedInteger
        {
            public bool IsInteger(){
                return true;
            }

            public int GetInteger(){
                return 0;
            }

            public List<NestedInteger> GetList(){
                return new List<NestedInteger>();
            }
        }
    }
}