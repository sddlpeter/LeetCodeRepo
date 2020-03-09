using System.Collections.Generic;
public class PhoneDirectory
{
    HashSet<int> used = new HashSet<int>();
    Queue<int> available = new Queue<int>();
    int max;

    public PhoneDirectory(int maxNumbers)
    {
        max = maxNumbers;
        for (int i = 0; i < maxNumbers; i++)
        {
            available.Enqueue(i);
        }
    }
    public int Get()
    {
        int ret = available.Count > 0 ? available.Dequeue() : -1;
        if (ret == -1) return -1;
        used.Add(ret);
        return ret;
    }
    public bool Check(int number)
    {
        if (number >= max || number < 0) return false;
        return !used.Contains(number);
    }
    public void Release(int number)
    {
        if (used.Remove(number))
        {
            available.Enqueue(number);
        }
    }
}