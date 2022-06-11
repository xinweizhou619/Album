//
//  CLBFileUtils.swift
//  CleanB-iOS
//
//  Created by xinweizhou on 2021/11/24.

import UIKit

class CLBFileUtils: NSObject {
    static func getHomeDir() -> String {
        return NSHomeDirectory()
    }
    static func getDocumentsDir() -> String { //D2FFDAD00B7E/Documents
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    static func getLibraryDir() -> String { // D2FFDAD00B7E/Library
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    
    static func getCachesDir() -> String { // D2FFDAD00B7E/Library/Caches
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
    static func getTmpDir() -> String {// D2FFDAD00B7E/tmp/
        return NSTemporaryDirectory()
    }

}

extension CLBFileUtils {
    
    static func copyItem(at srcPath: String, to dstPath: String) throws {
//        guard let srcU = URL(string: srcPath), let dstU = URL(string: dstPath) else {
//            let error = NSError(domain: "CleanA.CLBFileUtils", code: -1, userInfo: ["des":"path 错误"])
////            let error = CLAFileError()
//            throw error
//        }
        let srcU = URL(fileURLWithPath: srcPath)
        let dstU = URL(fileURLWithPath: dstPath)
        try FileManager.default.copyItem(at: srcU, to: dstU)
    }
    
    
    static func moveItem(at srcPath: String, to dstPath: String) throws {
        
        let srcU = URL(fileURLWithPath: srcPath)
        let dstU = URL(fileURLWithPath: dstPath)
        try FileManager.default.moveItem(at: srcU, to: dstU)
    }
    
    
    @discardableResult
    static func createDir(at path: String) -> Bool {
        do {// 重复创建没有问题，不会抛出错误
            try FileManager.default.createDirectory(at: URL(fileURLWithPath: path), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    static func isDir(at path: String) -> Bool {
        var isDir:ObjCBool = false // 如果路径不存在，则返回false
        let result = FileManager.default.fileExists(atPath: path, isDirectory: &isDir) // 路径（文件或者目录）存在返回ture
        if result {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }
    static func isFileExist(at path: String) -> Bool {
        var isDir:ObjCBool = false // 如果路径不存在，则返回false
        let result = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        if result {
            if !(isDir.boolValue) {
                return true
            }
        }
        return false
    }
    static func deleteDir(path: String) -> Bool {
        if !FileManager.default.fileExists(atPath: path) { // 当前路径不存在即不用删除
            return true
        } else {
            do { // 路径包括：文件，文件夹
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch {
                return false
            }
            
        }
    }
    
    static func creatFile(at path: String, with data: Data) -> Bool {
        // 跳路径不会成功，不会自动创建路径
        return FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    static func readFile(at path: String) ->Data? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions.mappedIfSafe)
            return data
        } catch {
            return nil
        }
    }
    
    static func deleteFile(at path: String) -> Bool {
        return self.deleteDir(path: path)
    }
    
    // 将文件夹大小转换为 M/KB/B
    static func sizeString(with size: NSInteger) -> String {
        var str = ""
        if (size >= 1024 * 1024) {
            str = str.appendingFormat("%.2f M", Float(size)/1024.00/1024.00)
        } else if (size >= 1024){
            str = str.appendingFormat("%.2f KB", Float(size)/1024.00)
        } else {
            str = str.appendingFormat("%.2f B", Float(size))
        }
        return str
    }
    
    static func getFilesSize(of path: String) -> NSInteger {
        
        var size:NSInteger = 0
        
        if self.isFileExist(at: path) { // 是否是文件
            let dict = try? FileManager.default.attributesOfItem(atPath: path)
            size = ((dict?[FileAttributeKey.size] as? NSInteger) ?? 0) + size
            print(size.self)
            return size
        }
        // subPath 是所有的树枝路径，包括叶子是文件夹的路径
        let subPathArray = try? FileManager.default.subpathsOfDirectory(atPath: path)
        guard let subPaths = subPathArray else {
            return size
        }

        for sub in subPaths {
            // 获取全路径URL
            var url = URL(fileURLWithPath: path)
            url.appendPathComponent(sub)
            
            //  以上判断目的是忽略不需要计算的文件（文件夹）
            var isDir:ObjCBool = false // 如果路径不存在，则返回false
            let result = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) // 路径（文件或者目录）存在返回ture
            if !result || isDir.boolValue || sub.contains(".DS") { // 过滤: 1. 文件夹不存在  2. 过滤文件夹  3. 隐藏文件
                continue
            }
          
            // 计算大小
            let dict = try? FileManager.default.attributesOfItem(atPath: url.path)
            size = ((dict?[FileAttributeKey.size] as? NSInteger) ?? 0) + size
    
        }
        return size
    }
    
    static func clearFiles(in path: String) -> Void {
        let subPathArray = try? FileManager.default.contentsOfDirectory(atPath: path)
        guard let pathArray = subPathArray else {
            return
        }
        
        for sub in pathArray {
            var url = URL(fileURLWithPath: path)
            url.appendPathComponent(sub)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error)
            }

        }
        
    }
}
