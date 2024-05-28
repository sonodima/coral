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

  public final class ProcessModuleIterator: __ProcessModuleIterator_Shared {
    private let _snapshot: HANDLE
    private var _entry: MODULEENTRY32W
    private var _done: Bool = false

    internal init(id: UInt) throws {
      // Specifying TH32CS_SNAPMODULE32 will include the 32-bit modules in the
      // snapshot, even for 64-bit processes.
      let flags = DWORD(TH32CS_SNAPMODULE32 | TH32CS_SNAPMODULE)
      guard let snapshot = CreateToolhelp32Snapshot(flags, DWORD(id)) else {
        throw SystemError.accessDenied
      }

      _snapshot = snapshot
      _entry = MODULEENTRY32W()
      _entry.dwSize = DWORD(MemoryLayout<MODULEENTRY32W>.size)
      if !Module32FirstW(_snapshot, &_entry) {
        if GetLastError() != ERROR_NO_MORE_FILES {
          throw SystemError.operationFailed
        } else {
          _done = true
        }
      }
    }

    deinit {
      CloseHandle(_snapshot)
    }

    public func next() -> ProcessModule? {
      guard !_done else {
        return nil
      }

      let name = withUnsafeBytes(of: _entry.szModule) { ptr in
        String.decodeCString(
          ptr.bindMemory(to: UInt16.self).baseAddress!,
          as: Unicode.UTF16.self)?.result
      }

      let module = ProcessModule(
        base: UInt(bitPattern: _entry.modBaseAddr),
        size: UInt(_entry.modBaseSize),
        name: name)

      _done = !Module32NextW(_snapshot, &_entry)
      return module
    }
  }

#endif
