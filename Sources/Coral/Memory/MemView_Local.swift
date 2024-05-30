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

#if os(Windows)

  import Foundation

  open class MemView_Local: MemView {
    private let _userView: MemView_User

    public init() throws {
      _userView = try MemView_User(for: OsProcess.local)
    }

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
      size: UInt = Platform.pageSize,
      protection: Protection
    ) -> MemRange? {
      _userView.allocate(at: address, size: size, protection: protection)
    }

    @discardableResult
    open func free(from address: UInt, size: UInt) -> Bool {
      _userView.free(from: address, size: size)
    }

    @discardableResult
    open func protect(at address: UInt, size: UInt, value: Protection) -> Bool {
      _userView.protect(at: address, size: size, value: value)
    }

    open func protection(at address: UInt) -> Protection? {
      _userView.protection(at: address)
    }
  }

#endif
