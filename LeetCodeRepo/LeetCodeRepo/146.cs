using System.Collections.Generic;

public class LRUCache
{
    private const int NotFound = -1;
    private int _count;
    private readonly int _capacity;
    private readonly LinkedList<CacheItem> _items;
    private readonly Dictionary<int, LinkedListNode<CacheItem>> _keys;

    public LRUCache(int capacity)
    {
        _items = new LinkedList<CacheItem>();
        _keys = new Dictionary<int, LinkedListNode<CacheItem>>(capacity);
        _count = 0;
        _capacity = capacity;
    }

    public int Get(int key)
    {
        if (!_keys.ContainsKey(key)) return NotFound;
        var cacheItem = _keys[key];
        if (cacheItem != _items.First)
        {
            _items.Remove(cacheItem);
            _items.AddFirst(cacheItem);
        }
        return cacheItem.Value.value;
    }

    public void Put(int key, int value)
    {
        if (!_keys.ContainsKey(key))
        {
            _keys[key] = _items.AddFirst(new CacheItem(key, value));
            if (_count == _capacity)
            {
                var last = _items.Last;
                _keys.Remove(last.Value.key);
                _items.RemoveLast();
            }
            else
            {
                _count++;
            }
        }
        else
        {
            var cacheItem = _keys[key];
            cacheItem.Value.value = value;

            if (cacheItem != _items.First)
            {
                _items.Remove(cacheItem);
                _items.AddFirst(cacheItem);
            }
        }
    }

    private class CacheItem
    {
        public CacheItem(int key, int value)
        {
            this.key = key;
            this.value = value;
        }

        public int key { get; }
        public int value { get; set; }
    }
}