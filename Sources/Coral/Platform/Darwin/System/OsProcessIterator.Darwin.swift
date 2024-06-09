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

  /// An iterator over the processes currently running on the system.
  ///
  /// Depending on the internal implementation, the iterator may fetch all processes at
  /// once or lazily.
  public final class OsProcessIterator: __OsProcessIterator_Shared {
    private let _pids: [pid_t]
    private var _index = 0

    internal init() throws {
      var count = proc_listallpids(nil, 0)
      guard count > 0 || errno != EPERM else {
        // Apps running in App Sandbox do not have permissions to list other running
        // processes.
        throw SystemError.accessDenied
      }

      // Account for the possibility of new processes being created while we are
      // counting the number of processes.
      count += count / 10
      _pids = try [pid_t](unsafeUninitializedCapacity: Int(count)) { buffer, outCount in
        let size = count * Int32(MemoryLayout<pid_t>.size)
        let count = proc_listallpids(buffer.baseAddress, size)
        if count <= 0 {
          throw SystemError.operationFailed
        }

        outCount = Int(count)
      }
    }

    public func next() -> OsProcess? {
      guard _index < _pids.count else {
        return nil
      }

      var process: OsProcess? = nil

      repeat {
        let id = _pids[_index]
        _index += 1
        process = OsProcess(id: UInt(id))
      } while process == nil && _index < _pids.count

      return process
    }
  }

#endif
