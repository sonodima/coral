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

public struct Pointer {
  public let view: any MemView
  public var address: UInt

  public var isZero: Bool {
    address == 0
  }

  public var protection: Protection? {
    view.protection(at: address)
  }

  public init(view: any MemView, to address: UInt) {
    self.view = view
    self.address = address
  }

  @discardableResult
  public func read(into buffer: UnsafeMutableRawBufferPointer) -> UInt {
    view.read(from: address, into: buffer)
  }

  @discardableResult
  public func write(data: UnsafeRawBufferPointer) -> UInt {
    view.write(to: address, data: data)
  }

  public func read<T>(as type: T.Type = T.self) -> T? {
    view.read(from: address, as: type)
  }

  @discardableResult
  public func write<T>(value: T, as type: T.Type = T.self) -> Bool {
    view.write(to: address, value: value, as: type)
  }

  public func read(as type: Self.Type = Self.self) -> Self? {
    view.read(from: address, as: type)
  }

  @discardableResult
  public func write(value: Self, as type: Self.Type = Self.self) -> Bool {
    view.write(to: address, value: value, as: type)
  }

  public func read<T>(count: Int, of type: T.Type = T.self) -> ContiguousArray<T> {
    view.read(from: address, count: count, of: type)
  }

  @discardableResult
  public func write<T>(array: ContiguousArray<T>, of type: T.Type = T.self) -> UInt {
    view.write(to: address, array: array, of: type)
  }

  public func read<E: Unicode.Encoding>(
    chars: Int,
    encoding: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> String {
    view.read(from: address, chars: chars, encoding: encoding, zeroTerm: zeroTerm)
  }

  @discardableResult
  public func write<E: Unicode.Encoding>(
    string: String,
    encoding: E.Type = Unicode.UTF8.self,
    zeroTerm: Bool = false
  ) -> Bool {
    view.write(to: address, string: string, encoding: encoding, zeroTerm: zeroTerm)
  }

  @discardableResult
  public func free(size: UInt) -> Bool {
    view.free(from: address, size: size)
  }

  @discardableResult
  public func protect(size: UInt, value: Protection) -> Bool {
    view.protect(at: address, size: size, value: value)
  }

  public func toRange(size: UInt) -> MemRange {
    MemRange(base: self, size: size)
  }

  public func toRange(end: Self) -> MemRange {
    MemRange(base: self, size: end.address >= address ? end.address - address : 0)
  }

  public func to<T>(_ lambda: (Self) -> T) -> T {
    lambda(self)
  }

  public func add(_ value: UInt) -> Self {
    Self(view: view, to: address &+ value)
  }

  public func sub(_ value: UInt) -> Self {
    Self(view: view, to: address &- value)
  }

  public func offset(_ value: Int) -> Self {
    Self(view: view, to: address &+ UInt(bitPattern: value))
  }

  public static func + (lhs: Self, rhs: UInt) -> Self {
    lhs.add(rhs)
  }

  public static func - (lhs: Self, rhs: UInt) -> Self {
    lhs.sub(rhs)
  }

  public static func += (lhs: inout Self, rhs: UInt) {
    lhs.address &+= rhs
  }

  public static func -= (lhs: inout Self, rhs: UInt) {
    lhs.address &-= rhs
  }
}

extension Pointer: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.address == rhs.address
  }
}

extension Pointer: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.address < rhs.address
  }
}

extension Pointer: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(address)
  }
}

extension Pointer: CustomDebugStringConvertible {
  public var debugDescription: String {
    let address = String(address, radix: 16, uppercase: true)
    return "Pointer(0x\(address))"
  }
}

extension Pointer: CustomStringConvertible {
  public var description: String {
    let address = String(address, radix: 16, uppercase: true)
    return "0x\(address)"
  }
}
