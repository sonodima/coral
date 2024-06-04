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
   
public protocol __Platform_Shared {
  /// The size of a page in bytes on the system.
  static var pageSize: UInt { get }

  /// The processor architecture of the system.
  /// 
  /// This value may differ from the architecture of the current process, if it is
  /// running with emulation or compatibility layers.
  static var architecture: Architecture { get }
}

extension __Platform_Shared {
  /// Returns the specified `value` aligned to the beginning of the page it is
  /// contained in.
  @inlinable
  @inline(__always)
  public static func alignStart(_ value: UInt) -> UInt {
    value & ~(pageSize - 1)
  }

  /// Returns the specified `value` aligned to the end of the page it is contained in.
  @inlinable
  @inline(__always) 
  public static func alignEnd(_ value: UInt) -> UInt {
    alignStart(value + (pageSize - 1))
  }

  /// A Boolean value indicating whether the current process is running with
  /// elevated privileges, or `nil` if the information is not available.
  public static var isElevated: Bool? {
    OsProcess.local.isElevated
  }
}
