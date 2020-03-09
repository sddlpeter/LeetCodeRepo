using static System.ValueTuple;
public class SnakeGame
{
    int curFoodIndex = -1;
    int[][] food;
    int row, col, headX = 0, headY = 0;
    List<(int x, int y)> snake = new List<(int x, int y)>();

    public SnakeGame(int width, int height, int[][] food)
    {
        var n = food.Length;
        if (n == 0) return;
        curFoodIndex = 0;
        this.row = height;
        this.col = width;
        this.food = food;
    }

    public int Move(string direction)
    {
        if (curFoodIndex == -1) return -1;
        int nextX;
        int nextY;

        if (direction == "U")
        {
            nextX = headX - 1;
            nextY = headY;
        }
        else if (direction == "L")
        {
            nextX = headX;
            nextY = headY - 1;
        }
        else if (direction == "R")
        {
            nextX = headX;
            nextY = headY + 1;
        }
        else
        {
            nextX = headX + 1;
            nextY = headY;
        }

        if (nextX < 0 || nextX >= row || nextY < 0 || nextY >= col) return -1;

        for (int i = 0; i < snake.Count; i++)
        {
            var position = snake[i];
            if (position.x == nextX && position.y == nextY) return -1;
        }

        snake.Add((nextX, nextY));

        if (curFoodIndex < food.Length && nextX == food[curFoodIndex][0] && nextY == food[curFoodIndex][1])
        {
            curFoodIndex++;
        }
        else snake.RemoveAt(0);

        headX = nextX;
        headY = nextY;

        return curFoodIndex;
    }