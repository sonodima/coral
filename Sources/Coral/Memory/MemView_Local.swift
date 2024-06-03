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

/// An implementation of ``MemView`` that performs memory operations on the local
/// process.
/// 
/// This implementation is close in speed to direct memory operations, but it will
/// raise an invalid access exception if the memory cannot be accessed.
open class MemView_Local: MemView {
  private let _userView: MemView_User

  public init() throws {
    // Most of the actual operations are delegated to the user view.
    _userView = try MemView_User(for: .local)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  open func read(
    from address: UInt,
    into buffer: UnsafeMutableRawBufferPointer
  ) -> UInt {
    if let src = UnsafeRawPointer(bitPattern: address),
      let dest = buffer.baseAddress
    {
      _ = memcpy(dest, src, buffer.count)
      return UInt(buffer.count)
    } else {
      return 0
    }
  }

  @inlinable
  @inline(__always)
  @discardableResult
  open func write(
    to address: UInt,
    data: UnsafeRawBufferPointer
  ) -> UInt {
    if let src = data.baseAddress,
      let dest = UnsafeMutableRawPointer(bitPattern: address)
    {
      _ = memcpy(dest, src, data.count)
      return UInt(data.count)
    } else {
      return 0
    }
  }

  open func allocate(
    at address: UInt? = nil,
    byteCount: UInt = Platform.pageSize,
    protection: Protection
  ) -> MemRange? {
    _userView.allocate(at: address, byteCount: byteCount, protection: protection)
  }

  @discardableResult
  open func free(from address: UInt, byteCount: UInt) -> Bool {
    _userView.free(from: address, byteCount: byteCount)
  }

  @discardableResult
  open func protect(at address: UInt, byteCount: UInt, value: Protection) -> Bool {
    _userView.protect(at: address, byteCount: byteCount, value: value)
  }

  open func protection(at address: UInt) -> Protection? {
    _userView.protection(at: address)
  }
}
