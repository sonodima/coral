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

  extension Protection {
    internal init(_ value: vm_prot_t) {
      let r = value & VM_PROT_READ == VM_PROT_READ
      let w = value & VM_PROT_WRITE == VM_PROT_WRITE
      let x = value & VM_PROT_EXECUTE == VM_PROT_EXECUTE
      
      self = switch (r, w, x) {
      case (true, true, true): .rwx
      case (true, true, _): .rw
      case (true, _, true): .rx
      case (true, _, _): .r
      case (_, _, true): .x
      default: .none
      }
    }

    internal var system: vm_prot_t {
      switch self {
      case .none: VM_PROT_NONE
      case .r: VM_PROT_READ
      case .x: VM_PROT_EXECUTE
      case .rw: VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY
      case .rx: VM_PROT_READ | VM_PROT_EXECUTE
      case .rwx: VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY | VM_PROT_EXECUTE
      }
    }
  }

#endif
