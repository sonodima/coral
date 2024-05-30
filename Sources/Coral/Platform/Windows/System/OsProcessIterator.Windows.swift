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

  public final class OsProcessIterator: __OsProcessIterator_Shared {
    private let _snapshot: HANDLE
    private var _entry: PROCESSENTRY32W
    private var _done: Bool = false

    internal init() throws {
      let flags = DWORD(TH32CS_SNAPPROCESS)
      guard let snapshot = CreateToolhelp32Snapshot(flags, 0) else {
        throw SystemError.accessDenied
      }

      _snapshot = snapshot
      _entry = PROCESSENTRY32W()
      _entry.dwSize = DWORD(MemoryLayout<PROCESSENTRY32W>.size)
      guard Process32FirstW(_snapshot, &_entry) else {
        throw SystemError.operationFailed
      }
    }

    deinit {
      CloseHandle(_snapshot)
    }

    public func next() -> OsProcess? {
      guard !_done else {
        return nil
      }

      var process: OsProcess? = nil

      repeat {
        process = OsProcess(entry: _entry)
        _done = !Process32NextW(_snapshot, &_entry)
      } while process == nil && !_done

      return process
    }
  }

#endif
