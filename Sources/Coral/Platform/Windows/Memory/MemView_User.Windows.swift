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

  open class MemView_User: __MemView_User_Shared {
    private var _handle: HANDLE

    required public init(for process: OsProcess) throws {
      if process.isLocal {
        _handle = GetCurrentProcess()
      } else {
        let access = DWORD(PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION)
        if let handle = OpenProcess(access, false, DWORD(process.id)) {
          _handle = handle
        } else {
          throw SystemError.accessDenied
        }
      }
    }

    deinit {
      if _handle != INVALID_HANDLE_VALUE && _handle != GetCurrentProcess() {
        CloseHandle(_handle)
      }
    }

    @discardableResult
    open func read(
      from address: UInt,
      into buffer: UnsafeMutableRawBufferPointer
    ) -> UInt {
      guard let dest = buffer.baseAddress.flatMap(UInt.init) else {
        return 0
      }

      // Limit the size to prevent overflow on the address.
      let size = min(UInt.max - dest, UInt(buffer.count))

      // Attempt a single read for the entire buffer. If we are lucky, we will avoid
      // the massive overhead of reading page by page.
      var curBytesRead: SIZE_T = 0
      if ReadProcessMemory(
        _handle,
        LPCVOID(bitPattern: address),
        LPVOID(bitPattern: dest),
        SIZE_T(size),
        &curBytesRead
      ) {
        return UInt(curBytesRead)
      }

      // Unfortunate! The single read failed, so we will read in chunks to get as much
      // data as possible.
      var bytesRead: UInt = 0
      while bytesRead < size {
        let chunkAddress = address + bytesRead
        let pageAddress = Platform.alignStart(chunkAddress)
        let pageOffset = chunkAddress - pageAddress
        let chunkSize = min(size - bytesRead, Platform.pageSize - pageOffset)

        if ReadProcessMemory(
          _handle,
          LPCVOID(bitPattern: chunkAddress),
          LPVOID(bitPattern: dest + bytesRead),
          SIZE_T(chunkSize),
          &curBytesRead
        ) {
          bytesRead += UInt(curBytesRead)
        } else {
          break
        }
      }

      return bytesRead
    }

    @discardableResult
    open func write(to address: UInt, data: UnsafeRawBufferPointer) -> UInt {
      guard let src = data.baseAddress else {
        return 0
      }

      var bytesWritten: SIZE_T = 0
      WriteProcessMemory(
        _handle,
        LPVOID(bitPattern: address),
        LPCVOID(src),
        SIZE_T(data.count),
        &bytesWritten)

      return UInt(bytesWritten)
    }

    open func allocate(
      at address: UInt? = nil,
      byteCount: UInt = Platform.pageSize,
      protection: Protection
    ) -> MemRange? {
      let type = protection == .none ? MEM_RESERVE : MEM_RESERVE | MEM_COMMIT
      return VirtualAllocEx(
        _handle,
        address.flatMap { LPVOID(bitPattern: $0) },
        SIZE_T(byteCount),
        DWORD(type),
        protection.system
      ).map { base in
        let address = UInt(bitPattern: base)
        return MemRange(base: ptr(to: address), size: byteCount)
      }
    }

    @discardableResult
    open func free(from address: UInt, byteCount: UInt) -> Bool {
      VirtualFreeEx(
        _handle,
        LPVOID(bitPattern: address),
        0,  // If dwFreeType is MEM_RELEASE, this parameter must be 0.
        DWORD(MEM_RELEASE))
    }

    @discardableResult
    open func protect(at address: UInt, byteCount: UInt, value: Protection) -> Bool {
      var _oldValue: DWORD = 0
      return VirtualProtectEx(
        _handle,
        LPVOID(bitPattern: address),
        SIZE_T(byteCount),
        value.system,
        &_oldValue)
    }

    open func protection(at address: UInt) -> Protection? {
      var info = MEMORY_BASIC_INFORMATION()
      let size = MemoryLayout<MEMORY_BASIC_INFORMATION>.size
      return VirtualQueryEx(
        _handle,
        LPCVOID(bitPattern: address),
        &info,
        SIZE_T(size)
      ) == size
        ? Protection(info.Protect)
        : nil
    }
  }

#endif
