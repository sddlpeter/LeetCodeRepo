namespace LeetCodeRepo
{
    public class Lc84
    {
        public int LargestRectangleArea(int[] heights)
        {
            int maxarea = 0;
            for (int i = 0; i < heights.Length; i++)
            {
                int minheight = int.MaxValue;
                for (int j = i; j < heights.Length; j++)
                {
                    minheight = Math.Min(minheight, heights[j]);
                    maxarea = Math.Max(maxarea, minheight * (j - i + 1));
                }
            }  
            return maxarea;
        }
    }

    public class Lc84_II
    {
        public int LargestRectangleArea(int[] heights)
        {
            Stack<int> stack = new Stack<int>();
            int maxarea = 0;
            stack.Push(-1);
            for (int i = 0; i < heights.Length; i++)
            {
                while (stack.Peek() != -1 && heights[i] <= heights[stack.Peek()])
                {
                    maxarea = Math.Max(maxarea, heights[stack.Pop()] * (i - stack.Peek() - 1));
                }
                stack.Push(i);
            }
            while (stack.Peek() != -1)
            {
                maxarea = Math.Max(maxarea, heights[stack.Pop()] * (heights.Length - stack.Peek()));
            }
            return maxarea;
        }
    }
}