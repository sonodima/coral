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
    private let _startTime: UInt64?

    public lazy var mainModule: ProcessModule? = {
      // On NT-based systems, the main module is the first module in the list.
      try? modules().first
    }()

    private var _path: URL?
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

    public var isElevated: Bool? {
      let access = DWORD(PROCESS_QUERY_LIMITED_INFORMATION)
      guard let handle = OpenProcess(access, false, DWORD(id)) else {
        return nil
      }

      defer { CloseHandle(handle) }

      var token: HANDLE?
      OpenProcessToken(handle, DWORD(TOKEN_QUERY), &token)
      guard let token = token else {
        return nil
      }

      var elevation = TOKEN_ELEVATION()
      var size = DWORD(MemoryLayout<TOKEN_ELEVATION>.size)
      guard GetTokenInformation(token, TokenElevation, &elevation, size, &size) else {
        return nil
      }

      return elevation.TokenIsElevated != 0
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

    public init?(name: String) {
      if let process = try? Self.iterate().first(where: { $0.name == name }) {
        self = process
      } else {
        return nil
      }
    }

    internal init?(entry: PROCESSENTRY32W) {
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

    public func iterateModules() throws -> ProcessModuleIterator {
      try ProcessModuleIterator(id: id)
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
