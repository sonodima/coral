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

  extension Architecture {
    internal static func fromSystem(_ value: WORD) -> Architecture {
      switch value {
      case WORD(PROCESSOR_ARCHITECTURE_AMD64): .x86_64
      case WORD(PROCESSOR_ARCHITECTURE_INTEL): .x86
      case WORD(PROCESSOR_ARCHITECTURE_ARM64): .arm64
      case WORD(PROCESSOR_ARCHITECTURE_ARM): .arm
      default: .unknown
      }
    }
  }

#endif
