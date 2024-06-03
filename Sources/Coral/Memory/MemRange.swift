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

import Foundation

/// A contiguous range of memory starting at a base pointer and spanning a number
/// of bytes.
///
/// The range does not own the memory it points to; it only provides an interface
/// to interact with it.
public struct MemRange {
  /// The pointer to the start of the range.
  public let base: RawPointer

  /// The number of bytes the range spans.
  public let size: UInt

  /// The view that the range is associated with.
  @inlinable
  @inline(__always)
  public var view: any MemView {
    base.view
  }

  /// A Boolean value indicating whether the range spans no bytes.
  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    size == 0
  }

  /// Creates an instance starting at `base` and spanning `size` bytes.
  @inlinable
  @inline(__always)
  public init(base: RawPointer, size: UInt) {
    self.base = base
    self.size = size
  }

  /// Reads the contents of the range as an array of bytes.
  public func read() -> ContiguousArray<UInt8> {
    base.read(maxCount: size, of: UInt8.self)
  }

  /// Returns an iterator over the matches of `pattern` in the range.
  public func scan(for pattern: Pattern) -> PointerPatternIterator {
    PointerPatternIterator(iterator: pattern.scan(in: read()), base: base)
  }

  /// Returns an iterator over the matches of `string` in the range.
  ///
  /// - Throws: ``PatternError`` if the pattern specified by `string` is invalid.
  public func scan(for string: String) throws -> PointerPatternIterator {
    scan(for: try Pattern(from: string))
  }

  /// Returns the first match of `pattern` in the range if it exists;
  /// otherwise, `nil`.
  public func find(pattern: Pattern) -> RawPointer? {
    pattern.find(in: read()).map(base.adding)
  }

  /// Returns the first match of `string` in the range if it exists;
  /// otherwise, `nil`.
  ///
  /// - Throws: ``PatternError`` if the pattern specified by `string` is invalid.
  public func find(signature: String) throws -> RawPointer? {
    find(pattern: try Pattern(from: signature))
  }

  /// Returns `true` if `other` is within the range of `self`; otherwise, `false`.
  @inlinable
  @inline(__always)
  public func contains(_ other: RawPointer) -> Bool {
    other >= base && other.address <= base.address + size
  }

  /// Returns `true` if `other` is entirely within the range of `self`;
  /// otherwise, `false`.
  @inlinable
  @inline(__always)
  public func contains(_ other: MemRange) -> Bool {
    other.base >= base && other.base.address + other.size <= base.address + size
  }

  /// Returns a ``RawPointer`` pointing to the memory at `offset` bytes from the
  /// start of the range if it is within the range; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func ptr(at offset: UInt) -> RawPointer? {
    offset < size ? base + offset : nil
  }

  /// Returns a ``RawPointer`` pointing to the memory at `offset` bytes from the
  /// start of the range if it is within the range; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public subscript(offset: UInt) -> RawPointer? {
    ptr(at: offset)
  }
}

extension MemRange: Equatable {
  /// Returns `true` if the two ranges are equal; otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func == (lhs: MemRange, rhs: MemRange) -> Bool {
    lhs.base == rhs.base && lhs.size == rhs.size
  }
}

extension MemRange: Hashable {
  /// Hashes the essential components of the range into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
    hasher.combine(size)
  }
}

extension MemRange: CustomDebugStringConvertible {
  /// A textual representation of the range, suitable for debugging.
  public var debugDescription: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.allowsNonnumericFormatting = false
    formatter.countStyle = .memory

    let address = String(base.address, radix: 16, uppercase: true)
    let size = formatter.string(fromByteCount: Int64(size))
    return "MemRange(base: 0x\(address), size: \(size))"
  }
}

extension MemRange: CustomStringConvertible {
  /// A textual representation of the range.
  public var description: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.allowsNonnumericFormatting = false
    formatter.countStyle = .memory

    let address = String(base.address, radix: 16, uppercase: true)
    let size = formatter.string(fromByteCount: Int64(size))
    return "MemRange - Base: 0x\(address), Size: \(size)"
  }
}
