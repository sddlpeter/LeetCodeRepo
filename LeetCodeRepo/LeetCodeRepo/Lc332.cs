using System.Collections.Generic;
namespace LeetCodeRepo{
    public class Lc332{
        public IList<string> FindItinerary(IList<IList<string>> tickets){
            LinkedList<string> res = new LinkedList<string>();
            //invalid input
            if (tickets == null || tickets.Count == 0) return res.ToList();
            //Build a hashtable/dict for route. 
            //key is the source city, value are all the destination city from source city.
            var routeDict = new Dictionary<string, List<string>>();

            int count = tickets.Count;   //tickets number
            for (int i = 0; i < count; i++)
            {
                var source = tickets[i][0];
                var dest = tickets[i][1];

                if (!routeDict.ContainsKey(source))
                    routeDict.Add(source, new List<string>());

                routeDict[source].Add(dest);
            }
            //keep asce order 
            foreach (var list in routeDict.Values) list.Sort();

            //need a stack as like a backtracking route from final.
            Stack<string> stack = new Stack<string>();
            stack.Push("JFK");    //Add start city
            while (stack.Any())
            {
                while (routeDict.ContainsKey(stack.Peek()) && routeDict[stack.Peek()].Any())
                {
                    var next = routeDict[stack.Peek()].First();  //the next city from the source city in lexical order
                    routeDict[stack.Peek()].RemoveAt(0);         //remove the next city from the hash table.(since List<T> doesn't has Poll/Pop/Dequeue)
                    stack.Push(next);                            //push next city into the stack
                }
                res.AddFirst(stack.Pop());                      //Pop all the city from stack, Add them in the head of res.
            }
            return res.ToList();
        }
    }
}