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
  import Foundation

  public struct OsProcess: __OsProcess_Shared {
    public static var local: Self = {
      let id = ProcessInfo.processInfo.processIdentifier
      // Force unwrap _should_ be safe here assuming that the process contructor only
      // returns nil if the process is not running, which will never be the case for
      // the current process.
      return Self(id: UInt(id))!
    }()

    private let _startSecs: UInt64?

    public let id: UInt
    public let name: String?
    public let architecture: Architecture
    public var isElevated: Bool?

    public var mainModule: ProcessModule? {
      try? ProcessModuleIterator(process: self).last()
    }

    private var _path: URL?
    public var path: URL? {
      // This getter is marked as mutating for the sake of consistency with other
      // implementations that perform lazy initialization of this property.
      //
      // Since we already need to fetch the path in the initializer to get the
      // name, we can avoid lazy initialization here.
      mutating get { _path }
    }

    public var isRunning: Bool? {
      if let value = Self.isRunningImpl(for: id) {
        // Check if the start times match, to ensure that this process identifier
        // has not been reused by the system.
        //
        // Note: This is accurate to the second, so there is a very very slim chance
        //       that the identifier could have been reused in the same second.
        //       Will it happen? Probably not.
        value && _startSecs == Self.taskAllInfo(for: id)?.pbsd.pbi_start_tvsec
      } else {
        nil
      }
    }

    public init?(id: UInt) {
      guard Self.isRunningImpl(for: id) == true else {
        return nil
      }

      self.id = id
      _path = Self.pathImpl(for: id)
      name = _path?.lastPathComponent
      architecture = Self.architectureImpl(for: id)

      let allInfo = Self.taskAllInfo(for: id)
      isElevated = allInfo?.pbsd.pbi_ruid == 0 /* root */
      _startSecs = allInfo?.pbsd.pbi_start_tvsec
    }

    public init?(name: String) {
      if let process = try? Self.iterate().first(where: { $0.name == name }) {
        self = process
      } else {
        return nil
      }
    }

    public func iterateModules() throws -> ProcessModuleIterator {
      try ProcessModuleIterator(process: self)
    }

    private static func pathImpl(for id: UInt) -> URL? {
      let max = Int(PROC_PIDPATHINFO_SIZE * 4)  // PROC_PIDPATHINFO_MAXSIZE
      let buffer = [UInt8](unsafeUninitializedCapacity: max) { buffer, outCount in
        let count = proc_pidpath(Int32(id), buffer.baseAddress, UInt32(max))
        outCount = Int(count)
      }

      if !buffer.isEmpty {
        let path = String(decoding: buffer, as: UTF8.self)
        return URL(fileURLWithPath: path)
      } else {
        return nil
      }
    }

    /// Credits: Patrick Wardle <https://www.patreon.com/posts/45121749>
    private static func architectureImpl(for id: UInt) -> Architecture {
      var mib = [Int32](repeating: 0, count: Int(CTL_MAXNAME))
      var length = mib.count
      guard sysctlnametomib("sysctl.proc_cputype", &mib, &length) == noErr else {
        return .unknown
      }

      mib[length] = Int32(id)
      length += 1

      var value = cpu_type_t()
      var size = MemoryLayout<cpu_type_t>.size
      guard sysctl(&mib, u_int(length), &value, &size, nil, 0) == noErr else {
        return .unknown
      }

      // For Apple Silicon we also need to check if the process binary has been
      // translated from x86_64 with Rosetta.
      if value == CPU_TYPE_ARM64 {
        mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, Int32(id)]
        length = mib.count

        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.size
        if sysctl(&mib, u_int(length), &info, &size, nil, 0) == noErr {
          if P_TRANSLATED == P_TRANSLATED & info.kp_proc.p_flag {
            return .x86_64
          }
        }
      }

      return Architecture(value)
    }

    private static func taskAllInfo(for id: UInt) -> proc_taskallinfo? {
      var info = proc_taskallinfo()
      let size = MemoryLayout<proc_taskallinfo>.size
      return proc_pidinfo(
        Int32(id),
        PROC_PIDTASKALLINFO,
        0,
        &info,
        Int32(size)
      ) == size ? info : nil
    }

    private static func isRunningImpl(for id: UInt) -> Bool? {
      var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid_t(id)]
      var value = kinfo_proc()
      var size = MemoryLayout<kinfo_proc>.size
      return if sysctl(&mib, 4, &value, &size, nil, 0) == noErr {
        value.kp_proc.p_pid > 0 && value.kp_proc.p_stat != SZOMB
      } else {
        nil
      }
    }
  }

  extension OsProcess: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.id == rhs.id && lhs._startSecs == rhs._startSecs
    }
  }

#endif
