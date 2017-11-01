//
//  EEGFileManager.swift
//  NaptimeBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import Files

extension Date {
    var toFileName: String {
        let fileFormatter = DateFormatter()
        fileFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return fileFormatter.string(from: self)
    }
}

extension DispatchQueue {
    static let file = DispatchQueue(label: "cn.entertech.NaptimeBLE.file")
}

extension FileManager {
    var dataDirectory: URL {
        let document = FileSystem(using: .default).documentFolder!
        try! document.createSubfolderIfNeeded(withName: "data")
        return URL(fileURLWithPath: try! document.subfolder(named: "data").path)
    }

    func fileURL(fileName: String) -> URL {
        return dataDirectory.appendingPathComponent("\(fileName).raw")
    }
}

class EEGFileManager {

    static let shared = EEGFileManager()

    private init() {}

    private var _fileHandle: FileHandle?

    private (set) var fileName: String?

    func create() {
        self.close()

        DispatchQueue.file.async {
            do {
                let fileName = Date().toFileName
                let fileURL = FileManager.default.fileURL(fileName: fileName)
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: [FileAttributeKey.protectionKey: FileProtectionType.none])
                }
                self._fileHandle = try FileHandle(forWritingTo: fileURL)
                self.fileName = fileName
            } catch {
                //
            }
        }
    }

    func save(data: Data) {
        DispatchQueue.file.async {
            self._fileHandle?.write(data)
        }
    }

    func close() {
        DispatchQueue.file.async {
            self._fileHandle?.closeFile()
            self.fileName = nil
        }
    }
}
