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

public struct Pointer<T> {
  public var raw: RawPointer

  public var address: UInt {
    raw.address
  }

  public var isZero: Bool {
    raw.isZero
  }

  public init(raw: RawPointer, for type: T.Type = T.self) {
    self.raw = raw
  }

  public init(view: any MemView, to address: UInt, for type: T.Type = T.self) {
    self.raw = RawPointer(view: view, to: address)
  }

  public func read() -> T? {
    raw.read(as: T.self)
  }

  @discardableResult
  public func write(value: T) -> Bool {
    raw.write(value: value, as: T.self)
  }

  public func add(_ value: UInt) -> Self {
    Self(raw: raw.add(value))
  }

  public func sub(_ value: UInt) -> Self {
    Self(raw: raw.sub(value))
  }

  public func offset(_ value: Int) -> Self {
    Self(raw: raw.offset(value))
  }

  public static func + (lhs: Self, rhs: UInt) -> Self {
    lhs.add(rhs)
  }

  public static func - (lhs: Self, rhs: UInt) -> Self {
    lhs.sub(rhs)
  }

  public static func += (lhs: inout Self, rhs: UInt) {
    lhs.raw += rhs
  }

  public static func -= (lhs: inout Self, rhs: UInt) {
    lhs.raw -= rhs
  }
}

extension Pointer: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.raw == rhs.raw
  }
}

extension Pointer: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.raw < rhs.raw
  }
}

extension Pointer: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(raw)
  }
}

extension Pointer: CustomDebugStringConvertible {
  public var debugDescription: String {
    let address = String(address, radix: 16, uppercase: true)
    return "Pointer<\(T.self)>(0x\(address))"
  }
}

extension Pointer: CustomStringConvertible {
  public var description: String {
    let address = String(address, radix: 16, uppercase: true)
    return "0x\(address)"
  }
}
