using System.Collections.Generic;
using System.Linq;

public class Twitter
{
    Dictionary<int, HashSet<int>> followerIdAndFolloweeList = new Dictionary<int, HashSet<int>>();
    Dictionary<int, IList<(int tweetId, int sequence)>> userIdAndTweetList = new Dictionary<int, IList<(int tweetId, int sequence)>>();

    int sequence = 1;
    public Twitter()
    {

    }

    public void PostTweet(int userId, int tweetId)
    {
        if (!userIdAndTweetList.ContainsKey(userId)) userIdAndTweetList[userId] = new List<(int tweetId, int sequence)>();
        userIdAndTweetList[userId].Add((tweetId, sequence));
        sequence++;
    }

    public IList<int> GetNewsFeed(int userId)
    {
        var result = new List<int>();
        if (!userIdAndTweetList.ContainsKey(userId)) return result;
        var usersId = new List<int>() { userId };

        if (followerIdAndFolloweeList.ContainsKey(userId))
        {
            usersId.AddRange(followerIdAndFolloweeList[userId]);
        }

        var curIndexList = new int[usersId.Count];
        for (int i = 0; i < usersId.Count; i++)
        {
            var curUserId = usersId[i];
            curIndexList[i] = userIdAndTweetList[curUserId].Count - 1;
        }

        while (result.Count < 10)
        {
            var isFinished = true;
            var tempResult = new List<(int tweetId, int sequence)>();
            for (int i = 0; i < usersId.Count; i++)
            {
                var curUserId = usersId[i];
                var curIndex = curIndexList[i];
                if (curIndex >= 0)
                {
                    tempResult.Add(userIdAndTweetList[curUserId][curIndex]);
                    isFinished = false;
                }
            }
            if (isFinished) return result;
            tempResult.Sort((a, b) => b.sequence - a.sequence);

            var min = tempResult.First();
            result.Add(min.tweetId);

            for (int i = 0; i < usersId.Count; i++)
            {
                var curUserId = usersId[i];
                var curIndex = curIndexList[i];
                if (curIndex >= 0)
                {
                    if (min.sequence == userIdAndTweetList[curUserId][curIndex].sequence)
                    {
                        curIndexList[i]--;
                    }
                }
            }

            if (result.Count > 10) return result;
        }
        return result;
    }


    public void Follow(int followerId, int followeeId)
    {
        if (followerId == followeeId) return;
        if (!userIdAndTweetList.ContainsKey(followerId)) userIdAndTweetList[followerId] = new List<(int tweetId, int sequence)>();
        if (!userIdAndTweetList.ContainsKey(followeeId)) userIdAndTweetList[followeeId] = new List<(int tweetId, int sequence)>();

        if (!followerIdAndFolloweeList.ContainsKey(followerId)) followerIdAndFolloweeList[followerId] = new HashSet<int>();
        followerIdAndFolloweeList[followerId].Add(followeeId);
    }

    public void Unfollow(int followerId, int followeeId)
    {
        if (followerIdAndFolloweeList.ContainsKey(followerId))
        {
            followerIdAndFolloweeList[followerId].Remove(followeeId);
        }
    }
}