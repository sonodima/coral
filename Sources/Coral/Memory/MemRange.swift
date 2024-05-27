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

public struct MemRange {
  public let base: RawPointer
  public let size: UInt

  public var view: any MemView {
    base.view
  }

  public var isEmpty: Bool {
    size == 0
  }

  public init(base: RawPointer, size: UInt) {
    self.base = base
    self.size = min(size, UInt.max - base.address)
  }

  public func ptr(at offset: UInt) -> RawPointer? {
    offset < size ? base + offset : nil
  }

  public func read() -> ContiguousArray<UInt8> {
    base.read(count: Int(bitPattern: size), of: UInt8.self)
  }

  public func scan(for pattern: Pattern) -> PointerPatternIterator {
    let data = read()
    let iterator = pattern.scan(in: data)
    return PointerPatternIterator(iterator: iterator, base: base)
  }

  public func scan(for string: String) throws -> PointerPatternIterator {
    let pattern = try Pattern(from: string)
    return scan(for: pattern)
  }

  public func find(pattern: Pattern) -> RawPointer? {
    let data = read()
    return pattern.find(in: data).map { base + UInt($0) }
  }

  public func find(string: String) throws -> RawPointer? {
    let pattern = try Pattern(from: string)
    return find(pattern: pattern)
  }

  public func contains(_ pointer: RawPointer) -> Bool {
    pointer >= base && pointer.address <= base.address + size
  }

  public func contains(_ other: Self) -> Bool {
    // This is safe, because we are sure that when a range is created, there can't be
    // a case in which summing base and size causes an overflow.
    other.base >= base && other.base.address + other.size <= base.address + size
  }

  public subscript(offset: UInt) -> RawPointer? {
    ptr(at: offset)
  }
}

extension MemRange: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base && lhs.size == rhs.size
  }
}

extension MemRange: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
    hasher.combine(size)
  }
}

extension MemRange: CustomDebugStringConvertible {
  public var debugDescription: String {
    let address = String(base.address, radix: 16, uppercase: true)

    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.countStyle = .memory
    let size = formatter.string(fromByteCount: Int64(size))

    return "MemRange(base: 0x\(address), size: \(size))"
  }
}

extension MemRange: CustomStringConvertible {
  public var description: String {
    let address = String(base.address, radix: 16, uppercase: true)

    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.countStyle = .memory
    let size = formatter.string(fromByteCount: Int64(size))

    return "MemRange - Base: 0x\(address), Size: \(size)"
  }
}
