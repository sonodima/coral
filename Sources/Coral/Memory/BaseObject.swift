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

open class BaseObject {
  /// The pointer to the object in memory.
  public let pointer: RawPointer

  /// The memory view that the object is associated with.
  @inlinable
  @inline(__always)
  public var view: any MemView {
    pointer.view
  }

  /// A Boolean value indicating whether the object points to a null memory location.
  @inlinable
  @inline(__always)
  public var isZero: Bool {
    pointer.isZero
  }

  /// Creates an instance from the given `pointer`.
  @inlinable
  @inline(__always)
  public init(_ pointer: RawPointer) {
    self.pointer = pointer
  }

  @discardableResult
  open func update() -> Self {
    return self
  }

  /// Converts this object to another type, using the provided constructor function.
  ///
  /// If the target type `T` has a constructor or a factory method that accepts a single
  /// ``RawPointer`` argument, you can use the following simplified syntax:
  ///
  /// ```swift
  /// obj.to(Player.init)
  /// ```
  ///
  /// This approach to conversion is very flexible, because it even allows the usage
  /// of fallible constructor methods, that may return `nil`.
  ///
  /// ```swift
  /// ptr.to(Player.tryFromPointer)?.health
  /// ```
  ///
  /// - Important: This operation only uses the pointer for conversion, so any cache or
  ///              object-specific values will not be transferred to the new object.
  @inlinable
  @inline(__always)
  public func to<T>(_ lambda: (RawPointer) -> T) -> T {
    lambda(pointer)
  }
}

extension BaseObject: Equatable {
  /// Returns `true` if the two objects point to the same memory location;
  /// otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func == (lhs: BaseObject, rhs: BaseObject) -> Bool {
    lhs.pointer == rhs.pointer
  }
}

extension BaseObject: Hashable {
  /// Hashes the essential components of the object into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(pointer)
  }
}

extension BaseObject: CustomDebugStringConvertible {
  /// Returns a textual representation of the object, suitable for debugging.
  public var debugDescription: String {
    let address = String(pointer.address, radix: 16, uppercase: true)
    return "\(type(of: self))(address: 0x\(address))"
  }
}

extension BaseObject: CustomStringConvertible {
  /// Returns a textual representation of the object.
  public var description: String {
    let address = String(pointer.address, radix: 16, uppercase: true)
    return "\(type(of: self)) - Address: 0x\(address)"
  }
}
