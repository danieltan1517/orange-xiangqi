heapify :: (array: [] int, index: int) {
  while true {
    largest := index;
    left := 2 * index + 1;
    right := 2 * index + 2;
 
    N := array.count;
 
    if left < N && array[left] > array[largest] then
      largest = left;
 
    if right < N && array[right] > array[largest] then
      largest = right;
 
    if largest != index then {
      temp := array[index];
      array[index] = array[largest];
      array[largest] = temp;
      index = largest;
    } else {
      break;
    }
  }
}

construct_heap :: (array: [] int) {
  count := array.count/2 - 1;
  for < index: count..0 {
    heapify(array, index);
  }
}

main :: () {

  array := int.[0, 5, 8, 10, 17, 103, 13, 19, 22, 24, 29];
  construct_heap(array);
  #import "Basic";
  print("%\n", array);


  N := array.count-1;
  for < i: N..0 {
    temp := array[0];
    array[0] = array[i];
    array[i] = temp;
    arr: [] int;
    arr.data = array.data;
    arr.count = i;
    heapify(arr, 0);
  }
  print("%\n", array);
}


