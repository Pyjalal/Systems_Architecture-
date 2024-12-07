### Report: Breadth-First Search in ARM Assembly

This ARM assembly program implements a **Breadth-First Search (BFS)** traversal on a binary tree stored as an array. The algorithm explores all nodes level by level and stores the result in an array. Below is an explanation of how the BFS traversal is performed step by step.

---

#### Initial Setup

The program begins by setting up several variables and data structures:

1. **Queue**: A temporary storage space for indices of nodes to visit.
2. **Result Array**: Stores the BFS traversal output.
3. **Pointers**:
   - `head` points to the front of the queue.
   - `tail` points to the next empty position in the queue.
4. **Initialisation**:
   - The root node (index 0) is enqueued.
   - `head` and `tail` pointers are set to initialise the queue.

---

#### BFS Loop

The BFS traversal begins in the `bfs_loop` section, where the queue is processed until it becomes empty:

1. **Dequeuing**:
   - The `head` pointer is used to retrieve the index of the current node from the queue.
   - The corresponding value in the `numbers` array is loaded and added to the `result` array.

2. **Enqueuing Children**:
   - For each node, the program calculates the indices of its left (`2*i + 1`) and right (`2*i + 2`) children.
   - If these indices are within bounds (i.e., less than the size of the array), they are enqueued using the `tail` pointer.

3. **Updating Pointers**:
   - After processing a node, the `head` pointer is incremented.
   - If child indices are enqueued, the `tail` pointer is updated to point to the next free slot in the queue.

This loop continues until all nodes are processed, i.e., when `head` equals `tail`.

---

#### Sorting the Result

After completing the BFS traversal, the program transitions to a **Bubble Sort** implementation to sort the `result` array. The `start_sort` section executes a nested loop structure:

1. **Outer Loop**:
   - Iterates through the `result` array, reducing the range of comparisons after each pass.

2. **Inner Loop**:
   - Compares adjacent elements. If they are out of order, the program swaps them using temporary storage in registers.

This process ensures the BFS traversal result is sorted in ascending order.

---

#### Conclusion

The program demonstrates how BFS can be implemented using an iterative queue-based approach. It systematically processes all nodes, calculates their child indices, and maintains order within the queue. The addition of a sorting algorithm at the end ensures that the output array is both a traversal and a sorted version of the tree. This implementation is efficient and adheres to the standard BFS methodology while leveraging ARM assembly's low-level instructions.
