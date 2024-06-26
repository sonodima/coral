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

#if os(macOS)

  import Darwin.Mach

  /// Provides information and utilities for the current system.
  public struct Platform: __Platform_Shared {
    public static var pageSize: UInt {
      UInt(vm_page_size)
    }

    public static var architecture: Architecture = {
      var value = cpu_type_t()
      var size = MemoryLayout<cpu_type_t>.size
      let result = sysctlbyname("hw.cputype", &value, &size, nil, 0)
      guard result != -1 else {
        return Architecture.unknown
      }

      return Architecture(value)
    }()
  }

#endif
