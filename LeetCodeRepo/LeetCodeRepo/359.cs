using System.Collections.Generic;
public class Logger
{

    private Dictionary<string, int> msgDict;
    public Logger()
    {
        msgDict = new Dictionary<string, int>();
    }

    public bool ShouldPrintMessage(int timestamp, string message)
    {
        if (!this.msgDict.ContainsKey(message))
        {
            this.msgDict.Add(message, timestamp);
            return true;
        }

        int oldTimestamp = this.msgDict[message];
        if (timestamp - oldTimestamp >= 10)
        {
            this.msgDict[message] = timestamp;
            return true;
        }
        else return false;
    }
}