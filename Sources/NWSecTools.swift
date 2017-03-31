//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWSecTools.swift
//  Pusher
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//
//  Modified by: Amr Aboelela on 3/13/17.
//

import Foundation
/** A collection of tools for reading, converting and inspecting Keychain objects and PKCS #12 files.

 This is practically the glue that connects this framework to the Security framework and allows interacting with the OS Keychain and PKCS #12 files. It is mostly an Objective-C around the Security framework, including the benefits of ARC. `NWIdentityRef`, `NWCertificateRef` and `NWKeyRef` represent respectively `SecIdentityRef`, `SecCertificateRef`, `SecKeyRef`. It uses Cocoa-style error handling, so methods return `nil` or `NO` if an error occurred.
 */
class NWSecTools {
    /** @name Initialization */
    /** Read an identity from a PKCS #12 file (.p12) that contains a single certificate-key pair. */
    class func identity(withPKCS12Data pkcs12: Data, password: String) throws -> SecIdentity? {
        let identities = try self.identities(withPKCS12Data: pkcs12, password: password)
        if identities.count == 0 {
            throw NWError.PKCS12NoItems
        }
        return identities.last
        return nil
    }
    
    /** Read all identities from a PKCS #12 file (.p12). */
    class func identities(withPKCS12Data pkcs12: Data, password: String) throws -> [SecIdentity] {
        guard pkcs12.count > 0 else {
            throw NWError.PKCS12EmptyData
        }
        let dicts = try self.allIdentities(withPKCS12Data: pkcs12, password: password)
        var ids: [SecIdentity] = [SecIdentity]()
        for dict in dicts {
            if let identity = dict[kSecImportItemIdentity as String] {
                ids.append(identity as! SecIdentity)
            }
        }
        return ids
    }

    class func allIdentities(withPKCS12Data data: Data, password: String) throws -> [[String : Any]] {
        var items: CFArray?
        var result: [[String : Any]] = [[String : Any]]()
        try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
            if let cfdata = CFDataCreate(kCFAllocatorDefault, bytes, data.count) {
                let options : [String : String] = [kSecImportExportPassphrase as String : password]
                print("options: \(options)")
                let status = SecPKCS12Import(cfdata, options as CFDictionary, &items)
                if status != errSecSuccess || items == nil {
                    throw NWError.PKCS12Error(status)
                }
                result = items as! [[String : Any]]
            }
        }
        return result
    }
}
