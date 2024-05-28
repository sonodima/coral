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

public protocol MemView {
  @discardableResult
  func read(from address: UInt, into buffer: UnsafeMutableRawBufferPointer) -> UInt

  @discardableResult
  func write(to address: UInt, data: UnsafeRawBufferPointer) -> UInt

  func allocate(at address: UInt?, size: UInt, protection: Protection) -> MemRange?

  @discardableResult
  func free(from address: UInt, size: UInt) -> Bool

  @discardableResult
  func protect(at address: UInt, size: UInt, value: Protection) -> Bool

  func protection(at address: UInt) -> Protection?
}

extension MemView {
  public func ptr(to address: UInt) -> RawPointer {
    RawPointer(view: self, to: address)
  }

  public func range(from module: ProcessModule) -> MemRange {
    ptr(to: module.base).toRange(size: module.size)
  }

  public func read<T>(from address: UInt, as type: T.Type = T.self) -> T? {
    assert(_isPOD(type), "Reading non-POD types is unsafe and not supported!")

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

  @discardableResult
  public func write<T>(to address: UInt, value: T, as type: T.Type = T.self) -> Bool {
    // Only allow writing plain-old-data types, that is, types that can be safely
    // copied to a raw memory buffer.
    assert(_isPOD(type), "Writing non-POD types is unsafe and not supported!")

    return withUnsafeBytes(of: value) { buffer in
      write(to: address, data: buffer) == buffer.count
    }
  }

  public func read(
    from address: UInt,
    as type: RawPointer.Type = RawPointer.self
  ) -> RawPointer? {
    read(from: address, as: UInt.self).map { value in
      RawPointer(view: self, to: value)
    }
  }

  @discardableResult
  public func write(
    to address: UInt,
    value: RawPointer,
    as type: RawPointer.Type = RawPointer.self
  ) -> Bool {
    write(to: address, value: value.address)
  }

  public func read<T>(
    from address: UInt,
    as type: Pointer<T>.Type = Pointer<T>.self
  ) -> Pointer<T>? {
    read(from: address, as: RawPointer.self).map { raw in
      Pointer(raw: raw, for: T.self)
    }
  }

  @discardableResult
  public func write<T>(
    to address: UInt,
    value: Pointer<T>,
    as type: Pointer<T>.Type = Pointer<T>.self
  ) -> Bool {
    write(to: address, value: value.raw)
  }

  public func read<T>(
    from address: UInt,
    count: Int,
    of type: T.Type = T.self
  ) -> ContiguousArray<T> {
    // Only allow reading arrays of plain-old-data, that is, types that can be safely
    // copied to a raw memory buffer.
    assert(_isPOD(T.self), "Reading non-POD types is unsafe and not supported!")

    // TODO: Handle arrays of RawPointer and Pointer<T> types.

    // Because the array allocates a contiguous memory buffer, we can safely read
    // directly into it.
    return ContiguousArray<T>(unsafeUninitializedCapacity: count) { buffer, outCount in
      let stride = UInt(MemoryLayout<T>.stride)

      if stride > 0 {
        let readBytes = read(from: address, into: UnsafeMutableRawBufferPointer(buffer))
        // Calculate the number of elements read, and adjust the buffer size accordingly.
        outCount = Int(readBytes / stride)
      } else {
        outCount = 0
      }
    }
  }

  @discardableResult
  public func write<T>(
    to address: UInt,
    array: ContiguousArray<T>,
    of type: T.Type = T.self
  ) -> UInt {
    // Only allow writing arrays of plain-old-data, that is, types that can be safely
    // copied to a raw memory buffer.
    assert(_isPOD(T.self), "Writing non-POD types is unsafe and not supported!")

    // TODO: Handle arrays of RawPointer and Pointer<T> types.

    // Because the array is guaranteed to be allocated continuously, we can write
    // its entire content directly.
    return array.withUnsafeBufferPointer { buffer in
      let writtenBytes = write(to: address, data: UnsafeRawBufferPointer(buffer))
      // Calculate the number of elements written.
      return writtenBytes / UInt(MemoryLayout<T>.stride)
    }
  }

  private func maxScalarWidth<E: Unicode.Encoding>(_ encoding: E.Type) -> Int {
    switch encoding {
    case is Unicode.UTF8.Type: 4
    case is Unicode.UTF16.Type: 2
    default: 1
    }
  }

  public func read<E: Unicode.Encoding>(
    from address: UInt,
    chars: Int,
    encoding: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> String {
    let count = chars * maxScalarWidth(encoding)
    var data = read(from: address, count: count, of: encoding.CodeUnit)
    if zeroTerm, let zeroIndex = data.firstIndex(of: E.CodeUnit.zero) {
      data.removeLast(data.count - zeroIndex)
    }

    let decoded = String(decoding: data, as: encoding)
    // Resize the string to be at most `chars` characters long.
    if let endIndex = decoded.index(
      decoded.startIndex,
      offsetBy: chars,
      limitedBy: decoded.endIndex
    ) {
      return String(decoded[..<endIndex])
    }

    return decoded
  }

  @discardableResult
  public func write<E: Unicode.Encoding>(
    to address: UInt,
    string: String,
    encoding: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> Bool {
    // This is basically a re-implementation on String.withCString(encodedAs:) with
    // minor changes because the new Foundation library is not complete yet.
    if encoding == Unicode.UTF8.self {
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
      to: encoding,
      stoppingOnError: false,
      into: { encoded.append($0) })
    if zeroTerm {
      encoded.append(E.CodeUnit.zero)
    }

    return write(to: address, array: encoded) == encoded.count
  }

  public subscript(address: UInt) -> RawPointer {
    ptr(to: address)
  }

  public subscript(module: ProcessModule) -> MemRange {
    range(from: module)
  }
}
