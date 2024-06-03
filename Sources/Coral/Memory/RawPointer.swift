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

/// A pointer to a memory location within a memory view.
/// 
/// The pointer does not own the memory it points to; it only provides an interface
/// to interact with it.
public struct RawPointer {
  /// The memory view that the pointer is associated with.
  public let view: any MemView

  /// The address of the memory location that the pointer points to.
  public var address: UInt

  /// A Boolean value indicating whether the pointer is null.
  @inlinable
  @inline(__always)
  public var isZero: Bool {
    address == 0
  }

  /// Creates an instance pointing to the specified `address` in `view`.
  @inlinable
  @inline(__always)
  public init(view: any MemView, to address: UInt) {
    self.view = view
    self.address = address
  }

  /// Copies the contents of the memory at the pointed location into `buffer`.
  ///
  /// - Returns: The number of bytes read from memory.
  @inlinable
  @inline(__always)
  @discardableResult
  public func read(into buffer: UnsafeMutableRawBufferPointer) -> UInt {
    view.read(from: address, into: buffer)
  }

  /// Copies the content of `data` to the memory at the pointed location.
  ///
  /// - Returns: The number of bytes written to memory.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write(data: UnsafeRawBufferPointer) -> UInt {
    view.write(to: address, data: data)
  }

  /// Reads a value of type `T` from the memory at the pointed location.
  ///
  /// - Returns: The value read from memory if successful; otherwise, `nil`.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  @inlinable
  @inline(__always)
  public func read<T>(as type: T.Type = T.self) -> T? {
    view.read(from: address, as: type)
  }

  /// Writes the given `value` to the memory at the pointed location.
  ///
  /// - Returns: `true` if the value was successfully written to memory;
  ///            otherwise, `false`.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(value: T, as type: T.Type = T.self) -> Bool {
    view.write(to: address, value: value, as: type)
  }

  /// Reads a ``RawPointer`` from the memory at the pointed location.
  ///
  /// - Returns: The pointer read from memory if successful; otherwise, `nil`.
  ///
  /// - SeeAlso: ``deref()``
  @inlinable
  @inline(__always)
  public func read(as type: RawPointer.Type = RawPointer.self) -> RawPointer? {
    view.read(from: address, as: type)
  }

  /// Writes a ``RawPointer`` to the memory at the pointed location.
  ///
  /// - Returns: `true` if the pointer was successfully written to memory;
  ///            otherwise, `false`.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write(
    value: RawPointer,
    as type: RawPointer.Type = RawPointer.self
  ) -> Bool {
    view.write(to: address, value: value, as: type)
  }

  /// Reads a ``Pointer`` to an instance of `T` from the memory at the pointed location.
  ///
  /// - Returns: The pointer read from memory if successful; otherwise, `nil`.
  ///
  /// - SeeAlso: ``deref(as:)``
  @inlinable
  @inline(__always)
  public func read<T>(as type: Pointer<T>.Type = Pointer<T>.self) -> Pointer<T>? {
    view.read(from: address, as: type)
  }

  /// Writes a ``Pointer`` to the memory at the pointed location.
  ///
  /// - Returns: `true` if the pointer was successfully written to memory;
  ///            otherwise, `false`.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(
    value: Pointer<T>,
    as type: Pointer<T>.Type = Pointer<T>.self
  ) -> Bool {
    view.write(to: address, value: value, as: type)
  }

  /// Reads an array of at most `maxCount` elements of type `T` from the memory at
  /// the pointed location.
  ///
  /// - Returns: The array read from memory if successful; otherwise, an empty array.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  @inlinable
  @inline(__always)
  public func read<T>(maxCount: UInt, of type: T.Type = T.self) -> ContiguousArray<T> {
    view.read(from: address, maxCount: maxCount, of: type)
  }

  /// Writes the given `array` to the memory at the pointed location.
  ///
  /// - Returns: The number of elements written to memory.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(array: ContiguousArray<T>, of type: T.Type = T.self) -> UInt {
    view.write(to: address, array: array, of: type)
  }

  /// Reads an array of at most `maxCount` pointers from the memory at the
  /// pointed location.
  ///
  /// - Returns: The array read from memory if successful; otherwise, an empty array.
  @inlinable
  @inline(__always)
  public func read(
    maxCount: UInt,
    of type: RawPointer.Type = RawPointer.self
  ) -> ContiguousArray<RawPointer> {
    view.read(from: address, maxCount: maxCount, of: type)
  }

  /// Writes the given `array` of pointers to the memory at the pointed location.
  ///
  /// - Returns: The number of elements written to memory.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write(
    array: ContiguousArray<RawPointer>,
    of type: RawPointer.Type = RawPointer.self
  ) -> UInt {
    view.write(to: address, array: array, of: type)
  }

  /// Reads an array of at most `maxCount` pointers to instances of `T` from the memory
  /// at the pointed location.
  ///
  /// - Returns: The array read from memory if successful; otherwise, an empty array.
  @inlinable
  @inline(__always)
  public func read<T>(
    maxCount: UInt,
    of type: Pointer<T>.Type = Pointer<T>.self
  ) -> ContiguousArray<Pointer<T>> {
    view.read(from: address, maxCount: maxCount, of: type)
  }

  /// Writes the given `array` of pointers to instances of `T` to the memory at the
  /// pointed location.
  ///
  /// - Returns: The number of elements written to memory.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(
    array: ContiguousArray<Pointer<T>>,
    of type: Pointer<T>.Type = Pointer<T>.self
  ) -> UInt {
    view.write(to: address, array: array, of: type)
  }

  /// Reads a string of at most `maxChars` characters from the memory at the
  /// pointed location.
  ///
  /// - Parameters:
  ///   - maxChars: The maximum number of characters to read.
  ///   - encoding: The encoding to use when decoding the string.
  ///   - zeroTerm: Whether to trim the string at the first zero character.
  ///
  /// - Returns: The string read from memory if successful; otherwise, an empty string.
  ///
  /// When possible, it is preferable to use the `Unicode.UTF8` encoding for writing
  /// strings, as it skips the transcoding step, which can be expensive.
  @inlinable
  @inline(__always)
  public func read<E: Unicode.Encoding>(
    maxChars: UInt,
    encoding: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> String {
    view.read(from: address, maxChars: maxChars, encoding: encoding, zeroTerm: zeroTerm)
  }

  /// Writes the given `string` to the memory at the pointed location.
  ///
  /// - Parameters:
  ///   - string: The string to write to memory.
  ///   - encodedAs: The encoding to use when encoding the string.
  ///   - zeroTerm: Whether to append a zero character at the end of the string.
  ///
  /// - Returns: `true` if the string was successfully written to memory;
  ///            otherwise, `false`.
  ///
  /// When possible, it is preferable to use the `Unicode.UTF8` encoding for writing
  /// strings, as it skips the transcoding step, which can be expensive.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<E: Unicode.Encoding>(
    string: String,
    encodedAs: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> Bool {
    view.write(to: address, string: string, encodedAs: encodedAs, zeroTerm: zeroTerm)
  }

  /// Reads a ``RawPointer`` from the memory at the pointed location.
  ///
  /// - Returns: The pointer read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func deref() -> RawPointer? {
    view.read(from: address, as: RawPointer.self)
  }

  /// Reads a ``Pointer`` to an instance of `T` from the memory at the pointed location.
  ///
  /// - Returns: The pointer read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func deref<T>(as type: T.Type = T.self) -> Pointer<T>? {
    view.read(from: address, as: Pointer<T>.self)
  }

  /// Frees `byteCount` bytes of memory starting from the pointed location.
  ///
  /// - Returns: `true` if the memory was successfully freed; otherwise, `false`.
  ///
  /// - Important: Some platforms do not support specifying the number of bytes to free.
  ///              In such cases, the entire memory allocation will be freed.
  @inlinable
  @inline(__always)
  @discardableResult
  public func free(byteCount: UInt) -> Bool {
    view.free(from: address, byteCount: byteCount)
  }

  /// Changes the protection level of the memory region at the pointed location.
  ///
  /// - Parameters:
  ///   - byteCount: The number of bytes to protect.
  ///   - value: The new protection level to apply.
  ///
  /// - Returns: `true` if the protection level was successfully changed;
  ///            otherwise, `false`.
  ///
  /// - Important: Some platforms restrict the ability to have pages that are both
  ///              writable and executable at the same time.
  @inlinable
  @inline(__always)
  @discardableResult
  public func protect(byteCount: UInt, value: Protection) -> Bool {
    view.protect(at: address, byteCount: byteCount, value: value)
  }

  /// The protection level of the memory at the pointed location, or `nil` if it cannot
  /// be determined.
  @inlinable
  @inline(__always)
  public var protection: Protection? {
    view.protection(at: address)
  }

  /// Returns the pointer as a typed pointer to an instance of `T`.
  @inlinable
  @inline(__always)
  public func typed<T>(as type: T.Type = T.self) -> Pointer<T> {
    Pointer(raw: self, for: type)
  }

  /// Converts this pointer to another type, using the provided constructor function.
  ///
  /// If the target type `T` has a constructor or a factory method that accepts a single
  /// ``RawPointer`` argument, you can use the following simplified syntax:
  ///
  /// ```swift
  /// ptr.to(Player.init)
  /// ```
  ///
  /// This approach to conversion is very flexible, because it even allows the usage
  /// of fallible constructor methods, that may return `nil`.
  ///
  /// ```swift
  /// ptr.to(Player.tryFromPointer)?.health
  /// ```
  @inlinable
  @inline(__always)
  public func to<T>(_ lambda: (RawPointer) -> T) -> T {
    lambda(self)
  }

  /// Returns a ``MemRange`` starting at the memory location pointed to by `self` and
  /// spanning `size` bytes.
  @inlinable
  @inline(__always)
  public func toRange(size: UInt) -> MemRange {
    MemRange(base: self, size: size)
  }

  /// Creates a ``MemRange`` starting at the memory location pointed to by `self` and
  /// spanning up to the memory location pointed to by `end`.
  /// 
  /// - Returns: The memory range if `end` is greater than or equal to `self`;
  ///            otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func toRange(end: RawPointer) -> MemRange? {
    if end >= self {
      MemRange(base: self, size: end.address - address)
    } else {
      nil
    }
  }

  /// Returns a ``RawPointer`` to the memory location pointed to by `self`, offset by
  /// `value` bytes.
  @inlinable
  @inline(__always)
  public func offset(_ value: Int) -> RawPointer {
    RawPointer(view: view, to: address &+ UInt(bitPattern: value))
  }

  /// Returns a ``RawPointer`` to the memory location pointed to by `self`, incremented
  /// by `value` bytes.
  @inlinable
  @inline(__always)
  public func adding(_ value: UInt) -> RawPointer {
    RawPointer(view: view, to: address + value)
  }

  /// Returns a ``RawPointer`` to the memory location pointed to by `self`, decremented
  /// by `value` bytes.
  @inlinable
  @inline(__always)
  public func subtracting(_ value: UInt) -> RawPointer {
    RawPointer(view: view, to: address - value)
  }

  /// Adds `value` to the address of the pointer.
  @inlinable
  @inline(__always)
  public mutating func add(_ value: UInt) {
    address += value
  }

  /// Subtracts `value` from the address of the pointer.
  @inlinable
  @inline(__always)
  public mutating func subtract(_ value: UInt) {
    address -= value
  }

  /// Returns a ``RawPointer`` to the memory location pointed to by `self`, incremented
  /// by `rhs` bytes.
  @inlinable
  @inline(__always)
  public static func + (lhs: RawPointer, rhs: UInt) -> RawPointer {
    lhs.adding(rhs)
  }

  /// Returns a ``RawPointer`` to the memory location pointed to by `self`, decremented
  /// by `rhs` bytes.
  @inlinable
  @inline(__always)
  public static func - (lhs: RawPointer, rhs: UInt) -> RawPointer {
    lhs.subtracting(rhs)
  }

  /// Adds `rhs` to the address of the pointer.
  @inlinable
  @inline(__always)
  public static func += (lhs: inout RawPointer, rhs: UInt) {
    lhs.add(rhs)
  }

  /// Subtracts `rhs` from the address of the pointer.
  @inlinable
  @inline(__always)
  public static func -= (lhs: inout RawPointer, rhs: UInt) {
    lhs.subtract(rhs)
  }
}

extension RawPointer: Equatable {
  /// Returns `true` if the two pointers point to the same address; otherwise, `false`.
  /// 
  /// Two pointers are considered equal if they point to the same address, regardless of
  /// the memory view they are associated with.
  @inlinable
  @inline(__always)
  public static func == (lhs: RawPointer, rhs: RawPointer) -> Bool {
    lhs.address == rhs.address
  }
}

extension RawPointer: Comparable {
  /// Returns `true` if `lhs` points to a lower address than `rhs`; otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func < (lhs: RawPointer, rhs: RawPointer) -> Bool {
    lhs.address < rhs.address
  }
}

extension RawPointer: Hashable {
  /// Hashes the essential components of the pointer into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(address)
  }
}

extension RawPointer: CustomDebugStringConvertible {
  /// A textual representation of the pointer, suitable for debugging.
  public var debugDescription: String {
    let address = String(address, radix: 16, uppercase: true)
    return "RawPointer(0x\(address))"
  }
}

extension RawPointer: CustomStringConvertible {
  /// A textual representation of the pointer.
  public var description: String {
    let address = String(address, radix: 16, uppercase: true)
    return "0x\(address)"
  }
}
