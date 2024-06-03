// Copyright (C) 2024 sonodima
// This file is part of the Coral project.
//
// Coral is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation, either
// version 3 of the License, or (at your option) any later version.
//
// Coral is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Coral.
// If not, see <https://www.gnu.org/licenses/>.

/// An iterator that scans a data buffer for a pattern, returning the indices of
/// its occurrences.
public final class PatternIterator: Sequence, IteratorProtocol {
  private let _pattern: Pattern
  private let _data: ContiguousArray<UInt8>
  private var _i: UInt = 0

  internal init(pattern: Pattern, in data: ContiguousArray<UInt8>) {
    _pattern = pattern
    _data = data
  }

  /// Searches for the next occurrence of the pattern in the data.
  /// 
  /// - Returns: The index of the next occurrence of the pattern in the data if
  ///            found; otherwise, `nil`.
  /// 
  /// - Complexity: O(n * m), where `n` is the length of the data and `m` is the
  ///               length of the pattern.
  public func next() -> UInt? {
    var result: UInt? = nil
    while _i <= _data.count - _pattern.data.count && result == nil {
      var found = true
      for j in 0..<_pattern.data.count {
        if let byte = _pattern.data[j], byte != _data[Int(_i) + j] {
          found = false
          break
        }
      }

      if found {
        result = _i
      }

      _i += 1
    }

    return result
  }
}

/// An iterator that scans a data buffer for a pattern, returning the pointers to
/// its occurrences relative to a base pointer.
public final class PointerPatternIterator: Sequence, IteratorProtocol {
  private var _iterator: PatternIterator
  private var _base: RawPointer

  internal init(iterator: PatternIterator, base: RawPointer) {
    _iterator = iterator
    _base = base
  }

  /// Searches for the next occurrence of the pattern in the data.
  /// 
  /// - Returns: The pointer to the next occurrence of the pattern in the data if
  ///            found; otherwise, `nil`.
  /// 
  /// - Complexity: O(n * m), where `n` is the length of the data and `m` is the
  ///               length of the pattern.
  public func next() -> RawPointer? {
    _iterator.next().map(_base.adding)
  }
}
