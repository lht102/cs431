# Lock-free hashtable
**Implement a lock-free hash table based on recursive split-ordered list.**

This homework is in 2 parts:
1. (140 points) Functionality:
   Implement the hash table with `Ordering::SeqCst` for every atomic access.
   With this, we can pretend that we are on a sequentially consistent memory model.
2. (40 points) Performance:
   After you learn about relaxed memory semantics,
   optimize the implementation by relaxing the ordering on the atomic accesses.

## Part 1: Split-ordered list in sequentially consistent memory model
1. Fully understand the following reading materials.
    + [The original paper on the split-ordered list](https://dl.acm.org/doi/abs/10.1145/1147954.1147958).
      You can skip the correctness proof and performance evaluation section.
    + Chapter 13.3 of [The Art of Multiprocessor Programming](https://www.amazon.com/Art-Multiprocessor-Programming-Revised-Reprint/dp/0123973376):
      Presents the same stuff, but is more readable.
      [pdf](https://dl.acm.org/doi/book/10.5555/2385452) of the book can be downloaded for free in KAIST.
    + The [lock-free linked list](https://github.com/kaist-cp/cs431/blob/main/src/lockfree/list.rs) interface and implementation.
1. Implement `GrowableArray` in [`hash_table/growable_array.rs`](../src/hash_table/growable_array.rs). (about 100 LOC)
    * You'll need to perform integer-pointer casts because `AtomicUsize` in `Segment` can be interpreted as both `Atomic<T>` and `Atomic<Segment>`.
      Use [`into_usize` and `from_usize`](https://docs.rs/crossbeam/*/crossbeam/epoch/trait.Pointer.html).
      See also: [#225](https://github.com/kaist-cp/cs431/issues/225)
    * To represent the height of the segment tree, [tag](https://en.wikipedia.org/wiki/Tagged_pointer) the `root` pointer with the height.
      Use [`tag`](https://docs.rs/crossbeam/*/crossbeam/epoch/struct.Shared.html#method.tag) and [`with_tag`](https://docs.rs/crossbeam/*/crossbeam/epoch/struct.Shared.html#method.with_tag).
      See [`lockfree/list.rs`](https://github.com/kaist-cp/cs431/blob/main/src/lockfree/list.rs) for example usage.
      See also: [#226](https://github.com/kaist-cp/cs431/issues/226)
1. Implement `SplitOrderedList` in [`hash_table/split_ordered_list.rs`](../src/hash_table/split_ordered_list.rs). (about 80 LOC)
    * You can use bitwise operations on `usize` e.g. `<<`, `&`, `|`, `^`, ...
      See also: [`leading_zeros`](https://doc.rust-lang.org/std/primitive.usize.html#method.leading_zeros), [`reverse_bits`](https://doc.rust-lang.org/std/primitive.usize.html#method.reverse_bits), [`size_of`](https://doc.rust-lang.org/std/mem/fn.size_of.html)
    * We provided type signatures for 2 helper methods for `SplitOrderedList`.
      You can modify/remove them or add more private methods if you want to.
      Just make sure you don't change the public interface. You can import other stuff from the `core` or `crossbeam_epoch` crates (but not necessary).

## Part 2: Relaxing the orderings
Use release-acquire synchronization for atomic accesses, just like many other data structures covered in the lecture.


## Testing
Tests in `tests/{growable_array,hash_table}.rs` use the map test functions defined in `tests/map/mod.rs`.
* `smoke`:
  Simple test case that tries a few operations. Useful for debugging.
* `stress_sequential`:
  Runs many operations in a single thread and tests if it works like a map data structure using `std::collections::HashMap` as reference.
* `lookup_concurrent`:
  Inserts keys sequentially, then concurrently run lookup in multiple threads.
* `insert_concurrent`:
  Inserts concurrently.
* `stress_concurrent`:
  Randomly runs many operations concurrently.
* `log_concurrent`:
  Randomly runs many operations concurrently and logs the operations & results per thread.
  Then checks the consistency of the log.
  For example, if the key `k` was successfully deleted twice, then `k` must have been inserted at least twice.
  Unlike `stress_sequential`, this test doesn't guarantee complete correctness.

## Grading (180 points)
Run `./scripts/grade-hash_table.sh`.

### Part 1: Functionality (140 points)
For each module `growable_array` and `split_ordered_list`,
the grader runs the tests with `cargo`, `cargo_asan`, and `cargo_tsan` in the following order.
1. `stress_sequential` (5 points)
1. `lookup_concurrent` (5 points)
1. `insert_concurrent` (10 points)
1. `stress_concurrent` (20 points)
1. `log_concurrent` (30 points)

Note:
* If a test fails in a module, then the later tests in the same module will not be run.
* The test timeout is at least 5x of the time our implementation took on the homework server.
  It is not a tight timeout, but it will detect clearly incorrect implementations.

### Part 2: Relaxed ordering (40 points)
For each module `growable_array` and `split_ordered_list`,
the grader checks the usage of `SeqCst` ordering and gives 20 points if it is not used.

Since `split_ordered_list` uses `growable_array`, using `SeqCst` in `growable_array` means it
is used in `split_ordered_list` as well.

## Submission
```bash
cd cs431/homework
./scripts/submit.sh
ls ./target/hw-hash_table.zip
```
Submit `hw-hash_table.zip` to gg.
