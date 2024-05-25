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
  import Foundation

  public struct OsProcess: __OsProcess_Shared {
    private static var _local: Self?
    public static var local: Self {
      if _local == nil {
        _local = Self(id: UInt(ProcessInfo.processInfo.processIdentifier))
      }

      return _local!
    }

    public let id: UInt
    public let name: String?
    public let architecture: Architecture
    public let _startTime: UInt64?

    private var _path: URL?

    public lazy var mainModule: OsModule? = {
      // On NT-based systems, the main module is the first module in the list.
      try? modules().first
    }()

    public var path: URL? {
      mutating get {
        let access = DWORD(PROCESS_QUERY_LIMITED_INFORMATION)
        if _path == nil, let handle = OpenProcess(access, false, DWORD(id)) {
          _path = Self.pathImpl(for: handle)
          CloseHandle(handle)
        }

        return _path
      }
    }

    public var isRunning: Bool? {
      let access = DWORD(PROCESS_QUERY_LIMITED_INFORMATION)
      guard let handle = OpenProcess(access, false, DWORD(id)) else {
        return nil
      }

      defer { CloseHandle(handle) }

      return Self.isRunningImpl(for: handle).map { value in
        // Check if the start time matches our previously stored value.
        // This is to prevent false positives in the case that the OS reuses the PID.
        value && _startTime == Self.startTimeImpl(for: handle)
      }
    }

    public init?(id: UInt) {
      let access = DWORD(PROCESS_QUERY_LIMITED_INFORMATION)
      guard let handle = OpenProcess(access, false, DWORD(id)) else {
        return nil
      }

      defer { CloseHandle(handle) }

      // Only allow the creation of a process if it is currently running on the system.
      guard Self.isRunningImpl(for: handle) != false else {
        return nil
      }

      self.id = id
      architecture = Self.architectureImpl(for: handle)
      _startTime = Self.startTimeImpl(for: handle)
      _path = Self.pathImpl(for: handle)
      name = _path?.lastPathComponent
    }

    private init?(entry: PROCESSENTRY32W) {
      let access = DWORD(PROCESS_QUERY_LIMITED_INFORMATION)
      guard let handle = OpenProcess(access, false, entry.th32ProcessID) else {
        return nil
      }

      defer { CloseHandle(handle) }

      id = UInt(entry.th32ProcessID)
      name = withUnsafeBytes(of: entry.szExeFile) { ptr in
        String.decodeCString(
          ptr.bindMemory(to: UInt16.self).baseAddress!,
          as: Unicode.UTF16.self)?.result
      }

      architecture = Self.architectureImpl(for: handle)
      _startTime = Self.startTimeImpl(for: handle)
    }

    public static func all() throws -> [Self] {
      let flags = DWORD(TH32CS_SNAPPROCESS)
      guard let snapshot = CreateToolhelp32Snapshot(flags, 0) else {
        throw SystemError.accessDenied
      }

      defer { CloseHandle(snapshot) }

      var entry = PROCESSENTRY32W()
      entry.dwSize = DWORD(MemoryLayout<PROCESSENTRY32W>.size)
      guard Process32FirstW(snapshot, &entry) else {
        throw SystemError.operationFailed
      }

      var processes: [Self] = []
      repeat {
        Self(entry: entry).map { processes.append($0) }
      } while Process32NextW(snapshot, &entry)
      return processes
    }

    public func modules() throws -> [OsModule] {
      // Specifying TH32CS_SNAPMODULE32 will include the 32-bit modules in the
      // snapshot, even for 64-bit processes.
      let flags = DWORD(TH32CS_SNAPMODULE32 | TH32CS_SNAPMODULE)
      guard let snapshot = CreateToolhelp32Snapshot(flags, DWORD(id)) else {
        throw SystemError.accessDenied
      }

      defer { CloseHandle(snapshot) }

      var entry = MODULEENTRY32W()
      entry.dwSize = DWORD(MemoryLayout<MODULEENTRY32W>.size)
      guard Module32FirstW(snapshot, &entry) else {
        if GetLastError() != ERROR_NO_MORE_FILES {
          throw SystemError.operationFailed
        } else {
          return []
        }
      }

      var modules: [OsModule] = []
      repeat {
        let address = UInt(bitPattern: entry.modBaseAddr)
        let size = UInt(entry.modBaseSize)
        let name = withUnsafeBytes(of: entry.szModule) { ptr in
          String.decodeCString(
            ptr.bindMemory(to: UInt16.self).baseAddress!,
            as: Unicode.UTF16.self)?.result
        }

        let module = OsModule(base: address, size: size, name: name)
        modules.append(module)
      } while Module32NextW(snapshot, &entry)
      return modules
    }

    private static func pathImpl(for handle: HANDLE) -> URL? {
      var buffer = [WCHAR](repeating: 0, count: Int(MAX_PATH))
      let length = K32GetModuleFileNameExW(handle, nil, &buffer, DWORD(buffer.count))
      guard length > 0 else {
        return nil
      }

      buffer.removeLast(buffer.count - Int(length))
      let path = String(decoding: buffer, as: Unicode.UTF16.self)
      return URL(fileURLWithPath: path)
    }

    private static func isRunningImpl(for handle: HANDLE) -> Bool? {
      var exitCode = DWORD()
      return if GetExitCodeProcess(handle, &exitCode) {
        exitCode == STILL_ACTIVE
      } else {
        nil
      }
    }

    private static func architectureImpl(for handle: HANDLE) -> Architecture {
      var isWow64 = WindowsBool(false)
      IsWow64Process(handle, &isWow64)

      // NOTE: This would probably break with 32-bit Windows on ARM stuff, but luckily
      //       that piece of crap is as dead as we all wish it was.
      return isWow64 == false ? Platform.architecture : .x86
    }

    private static func startTimeImpl(for handle: HANDLE) -> UInt64? {
      var creation = FILETIME()
      var _exit = FILETIME()
      var _kernel = FILETIME()
      var _user = FILETIME()
      return if GetProcessTimes(handle, &creation, &_exit, &_kernel, &_user) {
        UInt64(creation.dwHighDateTime) << 32 | UInt64(creation.dwLowDateTime)
      } else {
        nil
      }
    }
  }

  extension OsProcess: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id && lhs._startTime == rhs._startTime
    }
  }

#endif
