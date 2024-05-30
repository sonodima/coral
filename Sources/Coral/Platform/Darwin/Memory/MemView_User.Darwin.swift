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

  import Darwin

  public class MemView_User: __MemView_User_Shared {
    internal var task = mach_port_name_t(MACH_PORT_NULL)

    required public init(for process: OsProcess) throws {
      if process.isLocal {
        task = mach_task_self_
      } else if task_for_pid(
        mach_task_self_,
        Int32(process.id),
        &task
      ) != KERN_SUCCESS {
        throw SystemError.accessDenied
      }
    }

    deinit {
      if task != MACH_PORT_NULL && task != mach_task_self_ {
        mach_port_deallocate(mach_task_self_, task)
      }
    }

    @discardableResult
    public func read(
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
      var curBytesRead: mach_vm_size_t = 0
      if mach_vm_read_overwrite(
        task,
        mach_vm_address_t(address),
        mach_vm_size_t(size),
        mach_vm_address_t(dest),
        &curBytesRead
      ) == KERN_SUCCESS {
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

        // NOTE: According to frida-gum, mach_vm_read_overwrite leaks memory on macOS...
        //       Check it?
        if mach_vm_read_overwrite(
          task,
          mach_vm_address_t(chunkAddress),
          mach_vm_size_t(chunkSize),
          mach_vm_address_t(dest + bytesRead),
          &curBytesRead
        ) == KERN_SUCCESS {
          bytesRead += UInt(curBytesRead)
        } else {
          break
        }
      }

      return bytesRead
    }

    @discardableResult
    public func write(to address: UInt, data: UnsafeRawBufferPointer) -> UInt {
      guard let src = data.baseAddress else {
        return 0
      }

      return mach_vm_write(
        task,
        mach_vm_address_t(address),
        vm_offset_t(bitPattern: src),
        mach_msg_type_number_t(data.count)
      ) == KERN_SUCCESS ? UInt(bitPattern: data.count) : 0
    }

    public func allocate(
      at address: UInt? = nil,
      size: UInt = Platform.pageSize,
      protection: Protection
    ) -> MemRange? {
      var address = mach_vm_address_t(address ?? 0)
      if mach_vm_allocate(
        task,
        &address,
        mach_vm_size_t(size),
        address == 0 ? VM_FLAGS_ANYWHERE : 0
      ) != KERN_SUCCESS {
        return nil
      }

      // Allocation size is always rounded up to an integral number of pages.
      // The amount of memory allocated may be greater than the specified size.
      let size = Platform.alignEnd(size)
      if protect(at: UInt(address), size: size, value: protection) {
        return ptr(to: UInt(address)).toRange(size: size)
      } else {
        free(from: UInt(address), size: size)
        return nil
      }
    }

    @discardableResult
    public func free(from address: UInt, size: UInt) -> Bool {
      mach_vm_deallocate(
        task,
        mach_vm_address_t(address),
        mach_vm_size_t(size)
      ) == KERN_SUCCESS
    }

    @discardableResult
    public func protect(at address: UInt, size: UInt, value: Protection) -> Bool {
      // TODO: Check frida-gum's gum_mach_vm_protect, as they manually uses the
      //       vm_protect trap from assembly. The same is also done in Substrate.
      //       Maybe it is only required on iOS?
      mach_vm_protect(
        task,
        mach_vm_address_t(address),
        mach_vm_size_t(size),
        0 /* FALSE */,
        value.system
      ) == KERN_SUCCESS
    }

    public func protection(at address: UInt) -> Protection? {
      var startAddress = mach_vm_address_t(address)
      var objectName = mach_port_t()

      var regionSize = mach_vm_size_t()
      var regionInfo = vm_region_basic_info_data_t()
      var infoSize = mach_msg_type_number_t(
        MemoryLayout<vm_region_basic_info_data_t>.size)

      return withUnsafeMutablePointer(to: &regionInfo) { pointer in
        mach_vm_region(
          task,
          &startAddress,
          &regionSize,
          vm_region_flavor_t(VM_REGION_BASIC_INFO),
          UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: CInt.self),
          &infoSize,
          &objectName
        ) == KERN_SUCCESS
      } ? Protection(regionInfo.protection) : nil
    }
  }

#endif
