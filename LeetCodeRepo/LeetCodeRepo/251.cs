using System.Collections.Generic;

public class Vector2D
{
    int row = 0;
    int col = 0;
    int[][] v;
    public Vector2D(int[][] v)
    {
        this.v = v;
    }

    public int Next()
    {
        var result = v[row][col];
        col++;
        MoveToNextIndex();
        return result;
    }

    public bool HasNext()
    {
        MoveToNextIndex();
        return row != v.Length;
    }

    public void MoveToNextIndex()
    {
        while (row < v.Length && col == v[row].Length)
        {
            row++;
            col = 0;
        }
    }
}


public class Vector2D_II
{
    private readonly IList<int> _data;
    private int _counter = 0;

    public Vector2D_II(int[][] v)
    {
        _data = new List<int>();
        foreach (var vec in v)
        {
            foreach (var i in vec)
            {
                _data.Add(i);
            }
        }
    }

    public int Next() => _data[_counter++];
    public bool HasNext() => _counter < _data.Count;
}