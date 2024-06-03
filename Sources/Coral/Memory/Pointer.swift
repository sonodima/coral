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

public protocol __SomePointer {
  associatedtype Pointee
}

/// A typed pointer to an instance of `T` within a memory view.
/// 
/// The pointer does not own the memory it points to; it only provides an interface
/// to interact with it.
///
/// To avoid undefined behavior, the type `T` must be a trivial type that can be safely
/// copied to a raw memory buffer.
public struct Pointer<T>: __SomePointer {
  /// The type of the instance that the pointer points to.
  public typealias Pointee = T

  /// The internal raw pointer that the pointer wraps.
  public var raw: RawPointer

  /// The memory view that the pointer is associated with.
  @inlinable
  @inline(__always)
  public var view: any MemView {
    raw.view
  }

  /// The address of the memory location that the pointer points to.
  @inlinable
  @inline(__always)
  public var address: UInt {
    raw.address
  }

  /// A Boolean value indicating whether the pointer is null.
  @inlinable
  @inline(__always)
  public var isZero: Bool {
    raw.isZero
  }

  /// Creates an instance from the given `raw` pointer.
  @inlinable
  @inline(__always)
  public init(raw: RawPointer, for type: T.Type = T.self) {
    assert(_isPOD(type), "Pointers to non-trivial types are unsafe and not supported!")

    self.raw = raw
  }

  /// Creates an instance pointing to the specified `address` in `view`.
  @inlinable
  @inline(__always)
  public init(view: any MemView, to address: UInt, for type: T.Type = T.self) {
    assert(_isPOD(type), "Pointers to non-trivial types are unsafe and not supported!")

    raw = RawPointer(view: view, to: address)
  }

  /// Reads the value from the memory at the pointed location.
  ///
  /// - Returns: The value read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func deref() -> T? {
    raw.read(as: T.self)
  }

  /// Writes the given `value` to the memory at the pointed location.
  ///
  /// - Returns: `true` if the value was successfully written to memory;
  ///            otherwise, `false`.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write(value: T) -> Bool {
    raw.write(value: value, as: T.self)
  }

  /// Returns a ``Pointer`` to the instance of `T` pointed to by `self`, offset by
  /// `value` bytes.
  @inlinable
  @inline(__always)
  public func offset(_ value: Int) -> Pointer {
    Self(raw: raw.offset(value))
  }

  /// Returns a ``Pointer`` to the instance of `T` pointed to by `self`, incremented by
  /// `value` bytes.
  @inlinable
  @inline(__always)
  public func adding(_ value: UInt) -> Pointer {
    Self(raw: raw.adding(value))
  }

  /// Returns a ``Pointer`` to the instance of `T` pointed to by `self`, decremented by
  /// `value` bytes.
  @inlinable
  @inline(__always)
  public func subtracting(_ value: UInt) -> Pointer {
    Self(raw: raw.subtracting(value))
  }

  /// Adds `value` to the address of the pointer.
  @inlinable
  @inline(__always)
  public mutating func add(_ value: UInt) {
    raw.add(value)
  }

  /// Subtracts `value` from the address of the pointer.
  @inlinable
  @inline(__always)
  public mutating func subtract(_ value: UInt) {
    raw.subtract(value)
  }

  /// Returns a ``Pointer`` to the instance of `T` pointed to by `self`, incremented by
  /// `rhs` bytes.
  @inlinable
  @inline(__always)
  public static func + (lhs: Pointer, rhs: UInt) -> Pointer {
    lhs.adding(rhs)
  }

  /// Returns a ``Pointer`` to the instance of `T` pointed to by `self`, decremented by
  /// `rhs` bytes.
  @inlinable
  @inline(__always)
  public static func - (lhs: Pointer, rhs: UInt) -> Pointer {
    lhs.subtracting(rhs)
  }

  /// Adds `rhs` to the address of the pointer.
  @inlinable
  @inline(__always)
  public static func += (lhs: inout Pointer, rhs: UInt) {
    lhs.add(rhs)
  }

  /// Subtracts `rhs` from the address of the pointer.
  @inlinable
  @inline(__always)
  public static func -= (lhs: inout Pointer, rhs: UInt) {
    lhs.subtract(rhs)
  }
}

extension Pointer where T == RawPointer {
  /// Reads the value from the memory at the pointed location.
  ///
  /// - Returns: The value read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func deref() -> T? {
    raw.deref()
  }
}

extension Pointer where T: __SomePointer {
  /// Reads the value from the memory at the pointed location.
  ///
  /// - Returns: The value read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func deref() -> Pointer<T.Pointee>? {
    raw.deref(as: T.Pointee.self)
  }
}

extension Pointer: Equatable {
  /// Returns `true` if the two pointers point to the same address; otherwise, `false`.
  ///
  /// Two pointers are considered equal if they point to the same address, regardless of
  /// the memory view they are associated with.
  @inlinable
  @inline(__always)
  public static func == (lhs: Pointer, rhs: Pointer) -> Bool {
    lhs.raw == rhs.raw
  }
}

extension Pointer: Comparable {
  /// Returns `true` if `lhs` points to a lower address than `rhs`; otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Pointer, rhs: Pointer) -> Bool {
    lhs.raw < rhs.raw
  }
}

extension Pointer: Hashable {
  /// Hashes the essential components of the pointer into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(raw)
  }
}

extension Pointer: CustomDebugStringConvertible {
  /// Returns a textual representation of the pointer, suitable for debugging.
  public var debugDescription: String {
    let address = String(address, radix: 16, uppercase: true)
    return "Pointer<\(T.self)>(0x\(address))"
  }
}

extension Pointer: CustomStringConvertible {
  /// Returns a textual representation of the pointer.
  public var description: String {
    let address = String(address, radix: 16, uppercase: true)
    return "0x\(address)"
  }
}
