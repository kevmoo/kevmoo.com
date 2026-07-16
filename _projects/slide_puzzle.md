---
name: slide_puzzle
repo: kevmoo/slide_puzzle
featured: true
stars: 179
last_reviewed_sha: "c467500420f38fb75b6f9aaca30e2a2b5276a677"
last_reviewed_at: "2026-07-13T06:00:24.770515Z"
---

High-performance 15-puzzle $A^*$ solver and interactive web game built with **Dart 3** and **Flutter**.

Features:
* **50x Search Speedup**: Uses bit-packing into `Uint64`, static lookup tables, and an $O(1)$ amortized `_BucketQueue` to solve puzzles across 63,000+ loops in under 240ms.
* **Zero-Jank Web Solver**: Employs `async*` time-sliced batches yielding to the Flutter engine every 5ms so animations never drop frames.
