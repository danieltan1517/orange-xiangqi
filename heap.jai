heapify :: (queue: *Queue, index: int) {

  while true {
    largest := index;
    left := 2 * index + 1;
    right := 2 * index + 2;
 
    N := queue.count;
 
    if left < N && queue.array[left].priority > queue.array[largest].priority then
      largest = left;
 
    if right < N && queue.array[right].priority > queue.array[largest].priority then
      largest = right;

    if largest == index then
      break;
 
    temp := queue.array[index];
    queue.array[index] = queue.array[largest];
    queue.array[largest] = temp;
    index = largest;
  }

}

pop :: (queue: *Queue) -> move: Move32, priority: s32 {

  count := queue.count;
  move := queue.array[0].move;
  priority := queue.array[0].priority;
  queue.array[0] = queue.array[count];
  queue.count -= 1;
  heapify(queue, 0);
  return move, priority;

}

construct_heap :: (queue: *Queue) {

  count := queue.array.count/2 - 1;
  for < index: count..0 {
    heapify(queue, index);
  }

}

Queue :: struct {

  count: int;
  array: [127] Queue_Pair;

}

append :: (queue: *Queue, priority: s32, move: Move32) {

  index := queue.count;
  queue.array[index].priority = priority;
  queue.array[index].move = move;
  queue.count += 1;

}

#load "movegen.jai";

Queue_Pair :: struct {
  priority: s32;
  move: Move32;
  #place priority;
  #as data: u64;
}


main :: () {

  queue: Queue;
  move: Move32;
  append(*queue, 5, move);
  append(*queue, 8, move);
  append(*queue, 102, move);
  append(*queue, 10, move);
  append(*queue, 170, move);
  append(*queue, 1, move);
  construct_heap(*queue);

  for i: 0..queue.count-1 {

    print("%\n", queue.array[i].priority);

  }

  print("pop\n");
  while queue.count > 0 {
    m, p := pop(*queue);
    print("%\n", p);
  }




  /*for < i: N..0 {
    print("%\n", queue.array[queue.count].priority);
    /*temp := queue.array[0];
    queue.array[0] = queue.array[i];
    queue.array[i] = temp;
    heapify(*queue, 0);
    queue.count = i;*/
  }*/
  //print("%\n", queue);

/*
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
  print("%\n", array);*
*/
}


