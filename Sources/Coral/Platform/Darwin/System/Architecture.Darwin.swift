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

  extension Architecture {
    internal init(_ value: cpu_type_t) {
      self = switch value {
      case CPU_TYPE_X86_64: .x86_64
      case CPU_TYPE_X86: .x86
      case CPU_TYPE_ARM64: .arm64
      case CPU_TYPE_ARM: .arm
      // TODO: Should we add a case for arm64e? We would need to use the hw.cpusubtype
      //       sysctl to fetch it.
      default: .unknown
      }
    }
  }

#endif
