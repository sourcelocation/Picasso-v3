//
//  ReplaceOperation.swift
//  Picasso
//
//  Created by sourcelocation on 07/08/2023.
//

import Foundation
import URLBackport

public class ReplaceBundleOperation: Operation {
    @Published var path: String
    @Published var replacementFileName: String

    
    enum CodingKeys: String, CodingKey {
        case replacementFileName = "replacementFileName"
        case path = "originPath"
    }

    public init(path: String, replacementFileName: String, replacementFileBundled: Bool) {
        self.path = path
        self.replacementFileName = replacementFileName
        super.init(type: .replacing)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        replacementFileName = try container.decode(String.self, forKey: .replacementFileName)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(replacementFileName, forKey: .replacementFileName)
        try super.encode(to: encoder)
    }

    public override func perform(tweakURL: URL, preferences: [String: Any]) throws {
        if ExploitKit.shared.selectedExploit == .kfd {
            guard let apps = try? KFDApplicationManager.getApps(retainMountedOnly: ["com.apple.tips"]) else { throw "no apps L" }
            print(apps.map{ $0.name })
            
            guard let app = apps.first(where:{ app in
                app.bundleIdentifier == "com.apple.tips" // lmfao
            }) else {
                throw "Not found tips.app. You can try reinstalling the Tips app, rebooting and trying again."
            }
            let origin = app.mountedPoint.url.path + "/" + (path.replacingOccurrences(of: "Tips.app/", with: ""))
            
            
            let replacement = URL.backport(filePath: replacementFileName, relativeTo: tweakURL)
            
            
            let to_file_index = open(origin, O_RDONLY);
            if (to_file_index == -1) {
                print("\nto file nonexistent\n");
            }
            
            //        let to_file_size = (try FileManager.default.attributesOfItem(atPath: origin))[FileAttributeKey.size] as! UInt64  lseek(to_file_index, 0, SEEK_END);
            //        let origsize: Int = try Data(contentsOf: .init(fileURLWithPath: origin)).count
            try ExploitKit.shared.Overwrite(at: .init(fileURLWithPath: origin), with: .init(count: Int(735_136)))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print(replacement)
                print(try! Data(contentsOf: replacement))
                try? ExploitKit.shared.Overwrite(at: .init(fileURLWithPath: origin), withFileAtURL: replacement)
                
                try? KFD.unmountFileAtURL(mountURL: app.mountedPoint.url, orig_to_v_data: app.mountedPoint.vnode)
            }
        } else if ExploitKit.shared.selectedExploit == .mdc {
            do {
                let bundleAppPath = try getBundleDir(bundleID: "com.apple.tips")
                let replacement = URL.backport(filePath: replacementFileName, relativeTo: tweakURL)
                let executable = bundleAppPath.appendingPathComponent("Tips.app").appendingPathComponent("Tips")
                
                let origsize: Int = try Data(contentsOf: executable).count
                try ExploitKit.shared.Overwrite(at: executable, with: .init(count: origsize))
                try ExploitKit.shared.Overwrite(at: executable, with: .init(contentsOf: replacement))
                let helpercontents = try Data(contentsOf: replacement)
                let tipscontents = try Data(contentsOf: executable)
                print(tipscontents == helpercontents)
                if #available(iOS 16.0, *) { // bruh
                    print(tipscontents.contains(helpercontents))
                }
            } catch {
                throw error
            }
        } else {
            throw "Not implemented"
        }
        
        UIApplication.shared.alert(title: "Succcessfully overwritten Tips.app", body: "You may now reboot the phone, but use the REGULAR way of shutting down, not force reboot. Otherwise the file will revert upon startup.")
    }
}

fileprivate func getBundleDir(bundleID: String) throws -> URL {
    let fm = FileManager.default
    var returnedurl = URL(string: "none")
    var dirlist = [""]

    do {
        dirlist = try fm.contentsOfDirectory(atPath: "/var/containers/Bundle/Application")
        // print(dirlist)
    } catch {
        throw "Could not access /var/containers/Bundle/Application.\n\(error.localizedDescription)"
    }

    for dir in dirlist {
        // print(dir)
        let mmpath = "/var/containers/Bundle/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
        // print(mmpath)
        do {
            var mmDict: [String: Any]
            if fm.fileExists(atPath: mmpath) {
                mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]

                // print(mmDict as Any)
                if mmDict["MCMMetadataIdentifier"] as! String == bundleID {
                    returnedurl = URL(fileURLWithPath: "/var/containers/Bundle/Application").appendingPathComponent(dir)
                }
            } else {
                print("WARNING: Directory \(dir) does not have a metadata plist")
            }
        } catch {
            print("Could not get data of \(mmpath): \(error.localizedDescription)")
            throw ("Could not get data of \(mmpath): \(error.localizedDescription)")
        }
    }
    if returnedurl != URL(string: "none") {
        return returnedurl!
    } else {
        throw "App \(bundleID) cannot be found, is a system app, or is not installed."
    }
}
