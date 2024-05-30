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
  import Foundation

  import CDyld

  public final class ProcessModuleIterator: __ProcessModuleIterator_Shared {
    private let _view: MemView_User
    private let _imageInfos: ContiguousArray<dyld_image_info>
    private var _index = 0

    internal init(process: OsProcess) throws {
      let view = try MemView_User(for: process)

      var dyldInfo = task_dyld_info_data_t()
      var count = mach_msg_type_number_t(
        MemoryLayout<task_dyld_info_data_t>.stride / MemoryLayout<natural_t>.stride)
      let status = withUnsafeMutablePointer(to: &dyldInfo) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { dyldInfo in
          task_info(view.task, task_flavor_t(TASK_DYLD_INFO), dyldInfo, &count)
        }
      }

      guard status == KERN_SUCCESS else {
        throw SystemError.accessDenied
      }

      guard
        let allImageInfo = view.read(
          from: UInt(dyldInfo.all_image_info_addr),
          as: dyld_all_image_infos.self)
      else {
        throw SystemError.operationFailed
      }

      _imageInfos = view.read(
        from: UInt(bitPattern: allImageInfo.infoArray),
        count: Int(allImageInfo.infoArrayCount))
      _view = view
    }

    public func next() -> ProcessModule? {
      if let module = module(at: _index) {
        _index += 1
        return module
      } else {
        return nil
      }
    }

    /// Internal function to get the last module in the list. We use this to quickly
    /// get the main module for the process.
    /// 
    /// Although I did extensive testing and the last module is always the main module,
    /// I have not found any documentation that guarantees this.
    /// 
    /// If it turns out that this is not the case, we will have to look for the first
    /// module that has `filetype == MH_EXECUTE` _(booo, iteration is slow!)_
    internal func last() -> ProcessModule? {
      module(at: _imageInfos.count - 1)
    }

    private func module(at index: Int) -> ProcessModule? {
      guard index < _imageInfos.count && index >= 0 else {
        return nil
      }

      let imageInfo = _imageInfos[index]

      var path: URL? = nil
      if let address = imageInfo.imageFilePath {
        let rawPath = _view.read(
          from: UInt(bitPattern: address),
          chars: Int(PATH_MAX),
          encoding: Unicode.ASCII.self,
          zeroTerm: true)
        path = URL.init(fileURLWithPath: rawPath)
      }

      let imageLoadAddress = UInt(bitPattern: imageInfo.imageLoadAddress)
      let header = _view.ptr(to: imageLoadAddress, for: mach_header_64.self)
      return ProcessModule(
        base: imageLoadAddress,
        size: Self.sizeOfImage(header: header),
        path: path,
        name: path?.lastPathComponent)
    }

    /// TODO: Should we support 32-bit images as well? Do we really care about going
    ///       that far back in time?
    private static func sizeOfImage(header: Pointer<mach_header_64>) -> UInt {
      let headerSize = MemoryLayout<mach_header_64>.size
      var plc = header.raw.offset(headerSize)

      var size: UInt = 0x1000
      guard let header = header.read() else {
        return size
      }

      for _ in 0..<header.ncmds {
        guard let lc = plc.read(as: load_command.self) else {
          break
        }

        // This is questionable at best, but that's what you get for using tuples.
        // To be fair, we could decode the string here, but this is way faster.
        if lc.cmd == LC_SEGMENT_64 {
          guard let segment = plc.read(as: segment_command_64.self) else {
            break
          }

          if segment.segname.0 == 0x5F  // _
            && segment.segname.1 == 0x5F  // _
            && segment.segname.2 == 0x54  // T
            && segment.segname.3 == 0x45  // E
            && segment.segname.4 == 0x58  // X
            && segment.segname.5 == 0x54  // T
          {
            size = UInt(segment.vmsize)
            break
          }
        } else if lc.cmd == LC_SEGMENT {
          guard let segment = plc.read(as: segment_command.self) else {
            break
          }

          if segment.segname.0 == 0x5F  // _
            && segment.segname.1 == 0x5F  // _
            && segment.segname.2 == 0x54  // T
            && segment.segname.3 == 0x45  // E
            && segment.segname.4 == 0x58  // X
            && segment.segname.5 == 0x54  // T
          {
            size = UInt(segment.vmsize)
            break
          }
        }

        plc += UInt(lc.cmdsize)
      }

      return size
    }
  }

#endif
