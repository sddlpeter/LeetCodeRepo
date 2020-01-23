/*

INF  -1  0  INF
INF INF INF  -1
INF  -1 INF  -1
  0  -1 INF INF



  3  -1   0   1
  2   2   1  -1
  1  -1   2  -1
  0  -1   3   4

*/

namespace LeetCodeRepo{
    public class _286{
        public void WallsAndGates(int[][] rooms){
            if(rooms.Length == 0 || rooms[0].Length == 0) return;
            Queue<int[]> queue = new Queue<int[]>();
            for(int i = 0; i<rooms.Length; i++){
                for(int j = 0; j<rooms[0].Length; j++){
                    if(rooms[i][j] == 0) queue.Enqueue(new int[]{i, j});
                }
            }

            while(queue.Count>0){
                int[] top = queue.Dequeue();
                int row = top[0], col = top[1];
                if(row>0 && rooms[row-1][col] == int.MaxValue){
                    rooms[row-1][col] = rooms[row][col] +1;
                    queue.Enqueue(new int[]{row-1, col});
                }

                if(row<rooms.Length-1 && rooms[row+1][col] == int.MaxValue){
                    rooms[row+1][col] = rooms[row][col]+1;
                    queue.Enqueue(new int[]{row+1, col});
                }
                if(col>0 && rooms[row][col-1] == int.MaxValue){
                    rooms[row][col-1] = rooms[row][col] +1;
                    queue.Enqueue(new int[]{row, col-1});
                }
                if(col<rooms[0].Length-1 && rooms[row][col+1] == int.MaxValue){
                    rooms[row][col+1] = rooms[row][col] +1;
                    queue.Enqueue(new int[]{row, col+1});
                }
            }
        }
    }
}