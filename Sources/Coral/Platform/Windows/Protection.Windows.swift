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

  import WinSDK

  extension Protection {
    internal func toSystem() -> DWORD {
      switch self {
      case .none: DWORD(PAGE_NOACCESS)
      case .r: DWORD(PAGE_READONLY)
      case .x: DWORD(PAGE_EXECUTE)
      case .rw: DWORD(PAGE_READWRITE)
      case .rx: DWORD(PAGE_EXECUTE_READ)
      case .rwx: DWORD(PAGE_EXECUTE_READWRITE)
      }
    }

    internal static func fromSystem(_ value: DWORD) -> Protection {
      switch value {
      case DWORD(PAGE_EXECUTE_READWRITE): .rwx
      case DWORD(PAGE_READWRITE): .rw
      case DWORD(PAGE_EXECUTE_READ): .rx
      case DWORD(PAGE_READONLY): .r
      case DWORD(PAGE_EXECUTE): .x
      default: .none
      }
    }
  }

#endif
