/*
    Input:
    [
    "0010",
    "0110",
    "0100"
    ]
    and x = 0, y = 2

    Output: 6
*/


namespace LeetCodeRepo{
    public class Lc302{
        public int MinArea(char[][] image, int x, int y){
            int top = x, bottom = x;
            int left = y, right = y;
            for(x = 0; x<image.Length; x++){
                for(y = 0; y<image[0].Length; y++){
                    if(image[x][y] == '1'){
                        top = Math.Min(top, x);
                        bottom = Math.Max(bottom, x+1);
                        left = Math.Min(left, y);
                        right = Math.Max(right, y+1);
                    }
                }
            }
            return (right - left) * (bottom - top);
        }
    }
}