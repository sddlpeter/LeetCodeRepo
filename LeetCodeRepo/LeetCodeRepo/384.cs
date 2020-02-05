using System.Collections.Generic;
using System;

namespace LeetCodeRepo{

    //brute force method
    public class _384{
        private int[] array;
        private int[] original;
        private Random rand = new Random();

        private List<int> getArrayCopy(){
            List<int> asList = new List<int>();
            for(int i = 0; i<array.Length; i++){
                asList.Add(array[i]);
            }
            return asList;
        }
        public _384(){
            array = nums;
            original = (int[])nums.Clone();
        }

        public int[] Reset(){
            array = original;
            original = (int[])nums.Clone();
            return array;
        }

        public int[] Shuffle(){
            List<int> aux = getArrayCopy();
            for(int i = 0; i<array.Length; i++){
                int removeIdx = rand.Next(aux.Count);
                array[i] = aux(removeIdx);
                aux.RemoveAt(removeIdx);
            }
            return array;
        }
    }

// Fisher method
    public class _384_II{
        private int[] array;
        private int[] original;

        Random rand = new Random();
        private int randRange(int min, int max){
            return rand.Next(max - min) + min;
        }

        private void swapAt(int i, int j){
            int temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }

        public _384_II(int[] nums){
            array = nums;
            original = (int[])nums.Clone();
        }

        public int[] Reset(){
            array = original;
            original = (int[])original.Clone();
            return original;
        }

        public int[] Shuffle(){
            for(int i = 0; i<array.Length; i++){
                swapAt(i, randRange(i, array.Length));
            }
            return array;
        }
    }
}