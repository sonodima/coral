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

/// A protocol defining an interface for memory access and manipulation.
///
/// Implementations of this protocol can provide custom memory access strategies,
/// such as through a kernel driver or via hardware.
public protocol MemView {
  /// Copies the content of the memory at `address` into `buffer`.
  ///
  /// - Returns: The number of bytes read from memory.
  @discardableResult
  func read(from address: UInt, into buffer: UnsafeMutableRawBufferPointer) -> UInt

  /// Copies the content of `data` to the memory at `address`.
  ///
  /// - Returns: The number of bytes written to memory.
  @discardableResult
  func write(to address: UInt, data: UnsafeRawBufferPointer) -> UInt

  /// Allocates a new memory region with the given `protection` level.
  ///
  /// - Parameters:
  ///   - address: An optional address to allocate the memory at.
  ///   - byteCount: The minimum number of bytes to allocate.
  ///   - protection: The protection level to apply to the new memory region.
  ///
  /// - Returns: An instance of ``MemRange`` representing the allocated memory region
  ///            if successful; otherwise, `nil`.
  ///
  /// - Note: The allocated memory may be larger than `count` to satisfy alignment
  ///         requirements, and the actual address of the allocation may differ from
  ///         the requested `address`.
  ///
  /// - Important: Some platforms restrict the ability to allocate pages that are both
  ///              writable and executable at the same time.
  func allocate(at address: UInt?, byteCount: UInt, protection: Protection) -> MemRange?

  /// Frees `byteCount` bytes of memory starting from `address`.
  ///
  /// - Returns: `true` if the memory was successfully freed; otherwise, `false`.
  ///
  /// - Important: Some platforms do not support specifying the number of bytes to free.
  ///              In such cases, the entire memory allocation will be freed.
  @discardableResult
  func free(from address: UInt, byteCount: UInt) -> Bool

  /// Changes the protection level of the memory region at the given `address`.
  ///
  /// - Parameters:
  ///   - address: The memory address of the region to protect.
  ///   - byteCount: The number of bytes to protect.
  ///   - value: The new protection level to apply.
  ///
  /// - Returns: `true` if the protection level was successfully changed;
  ///            otherwise, `false`.
  ///
  /// - Important: Some platforms restrict the ability to have pages that are both
  ///              writable and executable at the same time.
  @discardableResult
  func protect(at address: UInt, byteCount: UInt, value: Protection) -> Bool

  /// Returns the protection level of the memory at the given `address` if successful;
  /// otherwise, `nil`.
  func protection(at address: UInt) -> Protection?
}

extension MemView {
  /// Reads a value of type `T` from the memory at the given `address`.
  ///
  /// - Returns: The value read from memory if successful; otherwise, `nil`.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  ///
  /// ```swift
  /// struct FooBar {
  ///   foo: CInt
  ///   bar: CFloat
  /// }
  ///
  /// let foo = view.read(from: 0x1000, as: CInt.self)
  /// let bar: CFloat? = view.read(from: 0x1004)
  ///
  /// let fooBar: FooBar? = view.read(from: 0x1000)
  /// ```
  @inlinable
  @inline(__always)
  public func read<T>(from address: UInt, as type: T.Type = T.self) -> T? {
    assert(_isPOD(type), "Reading non-trivial types is unsafe and not supported!")

    // This will attempt to stack-allocate the buffer when possible, and if not, it
    // will fall back to heap allocation.
    return withUnsafeTemporaryAllocation(of: type, capacity: 1) { buffer in
      let dest = UnsafeMutableRawBufferPointer(buffer)
      return if read(from: address, into: dest) == dest.count {
        buffer.moveElement(from: 0)
      } else {
        nil
      }
    }
  }

  /// Writes the given `value` to the memory at the specified `address`.
  ///
  /// - Returns: `true` if the value was successfully written to memory;
  ///            otherwise, `false`.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  ///
  /// ```swift
  /// struct FooBar {
  ///   foo: CInt
  ///   bar: CFloat
  /// }
  ///
  /// view.write(to: 0x1000, value: 420)
  /// view.write(to: 0x1008, value: 420, as: CFloat.self)
  ///
  /// let fooBar = FooBar(foo: 420, bar: 0.5)
  /// view.write(to: 0x1000, value: fooBar)
  /// ```
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(to address: UInt, value: T, as type: T.Type = T.self) -> Bool {
    assert(_isPOD(type), "Writing non-trivial types is unsafe and not supported!")

    return withUnsafeBytes(of: value) { buffer in
      write(to: address, data: buffer) == buffer.count
    }
  }

  /// Reads a ``RawPointer`` from the memory at the given `address`.
  ///
  /// - Returns: The pointer read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func read(
    from address: UInt,
    as type: RawPointer.Type = RawPointer.self
  ) -> RawPointer? {
    read(from: address, as: UInt.self).map { value in
      RawPointer(view: self, to: value)
    }
  }

  /// Writes a ``RawPointer`` to the memory at the specified `address`.
  ///
  /// - Returns: `true` if the pointer was successfully written to memory;
  ///            otherwise, `false`.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write(
    to address: UInt,
    value: RawPointer,
    as type: RawPointer.Type = RawPointer.self
  ) -> Bool {
    write(to: address, value: value.address)
  }

  /// Reads a ``Pointer`` to an instance of `T` from the memory at the given `address`.
  ///
  /// - Returns: The pointer read from memory if successful; otherwise, `nil`.
  @inlinable
  @inline(__always)
  public func read<T>(
    from address: UInt,
    as type: Pointer<T>.Type = Pointer<T>.self
  ) -> Pointer<T>? {
    read(from: address, as: RawPointer.self).map { raw in
      Pointer(raw: raw, for: T.self)
    }
  }

  /// Writes a ``Pointer`` to the memory at the specified `address`.
  ///
  /// - Returns: `true` if the pointer was successfully written to memory;
  ///            otherwise, `false`.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(
    to address: UInt,
    value: Pointer<T>,
    as type: Pointer<T>.Type = Pointer<T>.self
  ) -> Bool {
    write(to: address, value: value.raw)
  }

  /// Reads an array of at most `maxCount` elements of type `T` from the memory at
  /// the given `address`.
  ///
  /// - Returns: The array read from memory if successful; otherwise, an empty array.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  public func read<T>(
    from address: UInt,
    maxCount: UInt,
    of type: T.Type = T.self
  ) -> ContiguousArray<T> {
    assert(_isPOD(T.self), "Reading non-trivial types is unsafe and not supported!")

    // Because the array allocates a contiguous memory buffer, we can safely read
    // directly into it.
    return ContiguousArray<T>(
      unsafeUninitializedCapacity: Int(maxCount)
    ) { buffer, outCount in
      let stride = UInt(MemoryLayout<T>.stride)

      if stride > 0 {
        let readBytes = read(from: address, into: UnsafeMutableRawBufferPointer(buffer))
        outCount = Int(readBytes / stride)
      } else {
        outCount = 0
      }
    }
  }

  /// Writes the given `array` to the memory at the specified `address`.
  ///
  /// - Returns: The number of elements written to memory.
  ///
  /// To avoid undefined behavior, the type `T` must be a trivial type that can be
  /// safely copied to a raw memory buffer.
  @discardableResult
  public func write<T>(
    to address: UInt,
    array: ContiguousArray<T>,
    of type: T.Type = T.self
  ) -> UInt {
    assert(_isPOD(T.self), "Writing non-trivial types is unsafe and not supported!")

    let stride = UInt(MemoryLayout<T>.stride)
    return if stride > 0 {
      // Because the array is guaranteed to be allocated continuously, we can write
      // its entire content directly.
      array.withUnsafeBufferPointer { buffer in
        let writtenBytes = write(to: address, data: UnsafeRawBufferPointer(buffer))
        return writtenBytes / stride
      }
    } else {
      0
    }
  }

  /// Reads an array of at most `maxCount` pointers from the memory at the
  /// given `address`.
  ///
  /// - Returns: The array read from memory if successful; otherwise, an empty array.
  @inlinable
  @inline(__always)
  public func read(
    from address: UInt,
    maxCount: UInt,
    of type: RawPointer.Type = RawPointer.self
  ) -> ContiguousArray<RawPointer> {
    let array = read(from: address, maxCount: maxCount, of: UInt.self).map(ptr)
    return ContiguousArray(array)
  }

  /// Writes the given `array` of pointers to the memory at the specified `address`.
  ///
  /// - Returns: The number of elements written to memory.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write(
    to address: UInt,
    array: ContiguousArray<RawPointer>,
    of type: RawPointer.Type = RawPointer.self
  ) -> UInt {
    let values = array.map { $0.address }
    return write(to: address, array: ContiguousArray(values), of: UInt.self)
  }

  /// Reads an array of at most `maxCount` pointers to instances of `T` from the memory
  /// at the given `address`.
  ///
  /// - Returns: The array read from memory if successful; otherwise, an empty array.
  @inlinable
  @inline(__always)
  public func read<T>(
    from address: UInt,
    maxCount: UInt,
    of type: Pointer<T>.Type = Pointer<T>.self
  ) -> ContiguousArray<Pointer<T>> {
    let array = read(from: address, maxCount: maxCount, of: UInt.self).map {
      ptr(to: $0).typed(as: T.self)
    }

    return ContiguousArray(array)
  }

  /// Writes the given `array` of pointers to instances of `T` to the memory at the
  /// specified `address`.
  ///
  /// - Returns: The number of elements written to memory.
  @inlinable
  @inline(__always)
  @discardableResult
  public func write<T>(
    to address: UInt,
    array: ContiguousArray<Pointer<T>>,
    of type: Pointer<T>.Type = Pointer<T>.self
  ) -> UInt {
    let values = array.map { $0.address }
    return write(to: address, array: ContiguousArray(values), of: UInt.self)
  }

  /// Reads a string of at most `maxChars` characters from the memory at the
  /// given `address`.
  ///
  /// - Parameters:
  ///   - address: The memory address to read the string from.
  ///   - maxChars: The maximum number of characters to read.
  ///   - encoding: The encoding to use when decoding the string.
  ///   - zeroTerm: Whether to trim the string at the first zero character.
  ///
  /// - Returns: The string read from memory if successful; otherwise, an empty string.
  ///
  /// When possible, it is preferable to use the `Unicode.UTF8` encoding for writing
  /// strings, as it skips the transcoding step, which can be expensive.
  public func read<E: Unicode.Encoding>(
    from address: UInt,
    maxChars: UInt,
    encoding: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> String {
    let maxCount = maxChars * maxScalarWidth(encoding)
    var data = read(from: address, maxCount: maxCount, of: encoding.CodeUnit)
    if zeroTerm, let zeroIndex = data.firstIndex(of: E.CodeUnit.zero) {
      data.removeLast(data.count - zeroIndex)
    }

    var decoded = String(decoding: data, as: encoding)
    // Resize the string to be at most `maxChars` characters long.
    if let endIndex = decoded.index(
      decoded.startIndex,
      offsetBy: Int(maxChars),
      limitedBy: decoded.endIndex
    ) {
      decoded = String(decoded[..<endIndex])
    }

    return decoded
  }

  /// Writes the given `string` to the memory at the specified `address`.
  ///
  /// - Parameters:
  ///   - address: The memory address to write the string to.
  ///   - string: The string to write to memory.
  ///   - encodedAs: The encoding to use when encoding the string.
  ///   - zeroTerm: Whether to append a zero character at the end of the string.
  ///
  /// - Returns: `true` if the string was successfully written to memory;
  ///            otherwise, `false`.
  ///
  /// When possible, it is preferable to use the `Unicode.UTF8` encoding for writing
  /// strings, as it skips the transcoding step, which can be expensive.
  @discardableResult
  public func write<E: Unicode.Encoding>(
    to address: UInt,
    string: String,
    encodedAs: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> Bool {
    // This is basically a re-implementation on String.withCString(encodedAs:) with
    // minor changes because the new Foundation library is not complete yet.
    if encodedAs == Unicode.UTF8.self {
      var encoded = ContiguousArray(string.utf8)
      if zeroTerm {
        encoded.append(String.UTF8View.Element.zero)
      }

      return write(to: address, array: encoded) == encoded.count
    }

    // Slow path: we need to transcode the string before writing it.
    var encoded = ContiguousArray<E.CodeUnit>()
    encoded.reserveCapacity(string.count)
    _ = transcode(
      string.utf8.makeIterator(),
      from: Unicode.UTF8.self,
      to: encodedAs,
      stoppingOnError: false,
      into: { encoded.append($0) })
    if zeroTerm {
      encoded.append(E.CodeUnit.zero)
    }

    return write(to: address, array: encoded) == encoded.count
  }

  /// Returns a ``MemRange`` representing the memory region starting at `address`
  /// and extending `byteCount` bytes.
  @inlinable
  @inline(__always)
  public func range(from address: UInt, byteCount: UInt) -> MemRange {
    MemRange(base: ptr(to: address), size: byteCount)
  }

  /// Returns a ``MemRange`` representing the memory region of the given `module`.
  @inlinable
  @inline(__always)
  public func range(of module: ProcessModule) -> MemRange {
    range(from: module.base, byteCount: module.size)
  }

  /// Returns a ``RawPointer`` pointing to the memory at the given `address`.
  @inlinable
  @inline(__always)
  public func ptr(to address: UInt) -> RawPointer {
    RawPointer(view: self, to: address)
  }

  /// Returns a ``MemRange`` representing the memory region of the given `module`.
  @inlinable
  @inline(__always)
  public subscript(module: ProcessModule) -> MemRange {
    range(of: module)
  }

  /// Returns a ``RawPointer`` pointing to the memory at the given `address`.
  @inlinable
  @inline(__always)
  public subscript(address: UInt) -> RawPointer {
    ptr(to: address)
  }

  private func maxScalarWidth<E: Unicode.Encoding>(_ encoding: E.Type) -> UInt {
    switch encoding {
    case is Unicode.UTF8.Type: 4
    case is Unicode.UTF16.Type: 2
    default: 1
    }
  }
}
