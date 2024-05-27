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

public class BaseObject {
  public let pointer: RawPointer

  public var view: any MemView {
    pointer.view
  }

  public var isZero: Bool {
    pointer.isZero
  }

  public init(_ pointer: RawPointer) {
    self.pointer = pointer
  }

  @discardableResult
  public func update() -> Self {
    return self
  }

  public func map<T>(_ lambda: (RawPointer) -> T) -> T {
    lambda(pointer)
  }
}

extension BaseObject: Equatable {
  public static func == (lhs: BaseObject, rhs: BaseObject) -> Bool {
    lhs.pointer == rhs.pointer
  }
}

extension BaseObject: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(pointer)
  }
}

extension BaseObject: CustomStringConvertible {
  public var description: String {
    let address = String(pointer.address, radix: 16, uppercase: true)
    return "\(type(of: self)) - Address: 0x\(address)"
  }
}

extension BaseObject: CustomDebugStringConvertible {
  public var debugDescription: String {
    let address = String(pointer.address, radix: 16, uppercase: true)
    return "\(type(of: self))(address: 0x\(address))"
  }
}
