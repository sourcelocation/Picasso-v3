//// bomberfish
//// UDID.swift – Picasso
//// created on 2023-12-01
//
//import Foundation
//
//func getUDID() -> String? { // thanks airtroller
//    let frameworkURL = CFURLCreateWithFileSystemPath(kCFAllocatorSystemDefault, "/System/Library/PrivateFrameworks/AppleAccount.framework", .kCFURLPOSIXPathStyle, false)
//    let frameworkBundle = CFBundleCreate(kCFAllocatorSystemDefault, frameworkURL)
//    if !CFBundleLoadExecutable(frameworkBundle) {
//        return nil
//    }
//
//    let functionSymbolNames = ["udid"]
//
//    var functionSymbolDestinations = [UnsafeMutableRawPointer?](repeating: nil, count: functionSymbolNames.count)
//    functionSymbolDestinations.withUnsafeMutableBufferPointer { bufferPointer in
//        CFBundleGetFunctionPointersForNames(bundle, functionSymbolNames as CFArray, bufferPointer.baseAddress!)
//    }
//
//    func functionCast<T>(_ index: Int) -> T! {
//        return unsafeBitCast(functionSymbolDestinations[index]!, to: T.self)
//    }
//    
//    return nil // still wip lmao
//}
