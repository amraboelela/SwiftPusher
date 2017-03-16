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
        if let identities = try self.identities(withPKCS12Data: pkcs12, password: password) {
            if identities.count == 0 {
                throw NWError.PKCS12NoItems
            }
            /*if identities.count > 1 {
             throw NWError.PKCS12MultipleItems(count: identities.count) // //try? NWErrorUtil.nilWithErrorCode(kNWErrorPKCS12MultipleItems, reason: identities?.count)!
             }*/
            return identities.last
        }
        return nil
    }
    
    /** Read all identities from a PKCS #12 file (.p12). */
    class func identities(withPKCS12Data pkcs12: Data, password: String) throws -> [SecIdentity]? {
        guard pkcs12.count > 0 else {
            throw NWError.PKCS12EmptyData
        }
        if let dicts = try self.allIdentities(withPKCS12Data: pkcs12, password: password) {
            var ids = [SecIdentity]()
            for dict in dicts {
                if let identity = dict[kSecImportItemIdentity as String] {
                    /*if let certificate = try self.certificate(withIdentity: identity) {
                     if self.isPushCertificate(certificate) {
                     var key = try self.key(withIdentity: identity)
                     if key == nil {
                     return nil
                     }*/
                    ids.append(identity as! SecIdentity)
                    //}
                    //}
                }
            }
            return ids
        }
        return nil
    }
    
    /*
     /** List all push certificates present in the OS Keychain. */
     class func keychainCertificatesWithError(_ error: Error?) -> [Any] {
     var candidates: [Any]? = try? self.allKeychainCertificates()
     if candidates == nil {
     return nil
     }
     var certs = [Any]()
     for certificate: Any in candidates {
     if self.isPushCertificate(certificate) {
     certs.append(certificate)
     }
     }
     return certs
     }
     /** @name Sec Wrappers */
     /** Returns the certificate contained by the identity. */
     
     class func certificate(withIdentity identity: NWIdentityRef, error: Error?) -> NWCertificateRef {
     var cert: SecCertificateRef? = nil
     var status: OSStatus? = identity ? SecIdentityCopyCertificate((identity as? SecIdentityRef), cert) : errSecParam
     var certificate: NWCertificateRef = CFBridgingRelease(cert)
     if status != errSecSuccess || !cert {
     return try? NWErrorUtil.nilWithErrorCode(kNWErrorIdentityCopyCertificate, reason: status)!
     }
     return certificate
     }
     /** Returns the key contained by the identity. */
     
     class func key(withIdentity identity: NWIdentityRef, error: Error?) -> NWKeyRef {
     var k: SecKeyRef? = nil
     var status: OSStatus? = identity ? SecIdentityCopyPrivateKey((identity as? SecIdentityRef), k) : errSecParam
     var key: NWKeyRef = CFBridgingRelease(k)
     if status != errSecSuccess || !k {
     return try? NWErrorUtil.nilWithErrorCode(kNWErrorIdentityCopyPrivateKey, reason: status)!
     }
     return key
     }
     /** Reads an X.509 certificate from a DER file. */
     
     class func certificate(with data: Data) -> NWCertificateRef {
     return data ? CFBridgingRelease(SecCertificateCreateWithData(kCFAllocatorDefault, (data as? CFDataRef))) : nil!
     }
     #if !TARGET_OS_IPHONE
     /** Searches the OS Keychain for an identity (the key) that matches the certificate. (OS X only) */
     
     class func keychainIdentity(withCertificate certificate: NWCertificateRef, error: Error?) -> NWIdentityRef {
     var ident: SecIdentityRef? = nil
     var status: OSStatus? = certificate ? SecIdentityCreateWithCertificate(nil, (certificate as? SecCertificateRef), ident) : errSecParam
     var identity: NWIdentityRef = CFBridgingRelease(ident)
     if status != errSecSuccess || !ident {
     switch status {
     case errSecItemNotFound:
     return try? NWErrorUtil.nilWithErrorCode(kNWErrorKeychainItemNotFound)!
     }
     
     return try? NWErrorUtil.nilWithErrorCode(kNWErrorKeychainCreateIdentity, reason: status)!
     }
     return identity
     }
     #endif
     /** @name Inspection */
     /** Extracts the summary string. */
     
     class func summary(withCertificate certificate: NWCertificateRef) -> String {
     var result: String? = nil
     self.type(withCertificate: certificate, summary: result)
     return result!
     }
     /** Tells what environment options can be used with this identity (Development(sandbox)/Production server or both). */
     
     class func environmentOptions(forIdentity identity: NWIdentityRef) -> NWEnvironmentOptions {
     var certificate: NWCertificateRef? = try? self.certificate(withIdentity: identity)
     return self.environmentOptions(forCertificate: certificate)
     }
     /** Tells what environment options can be used with this certificate (Development(sandbox)/Production server or both). */
     
     class func environmentOptions(forCertificate certificate: NWCertificateRef) -> NWEnvironmentOptions {
     switch self.type(withCertificate: certificate, summary: nil) {
     case kNWCertTypeIOSDevelopment, kNWCertTypeMacDevelopment:
     return NWEnvironmentOptionSandbox
     case kNWCertTypeIOSProduction, kNWCertTypeMacProduction:
     return NWEnvironmentOptionProduction
     case kNWCertTypeSimplified, kNWCertTypeWebProduction, kNWCertTypeVoIPServices, kNWCertTypeWatchKitServices:
     return NWEnvironmentOptionAny
     case kNWCertTypeNone, kNWCertTypeUnknown:
     break
     }
     
     return NWEnvironmentOptionNone
     }
     /** Tells if the certificate can be used for connecting with APNs. */
     
     class func isPushCertificate(_ certificate: NWCertificateRef) -> Bool {
     switch self.type(withCertificate: certificate, summary: nil) {
     case kNWCertTypeIOSDevelopment, kNWCertTypeMacDevelopment, kNWCertTypeIOSProduction, kNWCertTypeMacProduction, kNWCertTypeSimplified, kNWCertTypeWebProduction, kNWCertTypeVoIPServices, kNWCertTypeWatchKitServices:
     return true
     case kNWCertTypeNone, kNWCertTypeUnknown:
     break
     }
     
     return false
     }
     /** Composes a dictionary describing the characteristics of the identity. */
     
     class func inspectIdentity(_ identity: NWIdentityRef) -> [AnyHashable: Any] {
     if identity == nil {
     return nil
     }
     var result: [AnyHashable: Any] = [:]
     var certificate: SecCertificateRef? = nil
     var certstat: OSStatus? = SecIdentityCopyCertificate((identity as? SecIdentityRef), certificate)
     result["has_certificate"] = (!!certificate)
     if certstat != nil {
     result["certificate_error"] = (certstat)
     }
     if certificate != nil {
     result["subject_summary"] = CFBridgingRelease(SecCertificateCopySubjectSummary(certificate))
     result["der_data"] = CFBridgingRelease(SecCertificateCopyData(certificate))
     }
     var key: SecKeyRef? = nil
     var keystat: OSStatus? = SecIdentityCopyPrivateKey((identity as? SecIdentityRef), key)
     result["has_key"] = (!!key)
     if keystat != nil {
     result["key_error"] = (keystat)
     }
     if key != nil {
     result["block_size"] = (SecKeyGetBlockSize(key))
     }
     return result
     }
     #if !TARGET_OS_IPHONE
     /** Extracts the expiration date. */
     
     class func expiration(withCertificate certificate: NWCertificateRef) -> Date {
     return self.value(withCertificate: certificate, key: (kSecOIDInvalidityDate as? Any))!
     }
     /** Extracts given properties of certificate, see `SecCertificateOIDs.h`, use `nil` to get all. */
     
     class func values(withCertificate certificate: NWCertificateRef, keys: [Any], error: Error?) -> [AnyHashable: Any] {
     var e: CFErrorRef? = nil
     var result: [AnyHashable: Any]? = CFBridgingRelease(SecCertificateCopyValues((certificate as? SecCertificateRef), (keys as? CFArrayRef), e))
     if error != nil {
     error = CFBridgingRelease(e)
     }
     return result!
     }
     #endif
     // deprecated
     
     class func isSandboxIdentity(_ identity: NWIdentityRef) -> Bool {
     return self.environment(forIdentity: identity) == NWEnvironmentSandbox
     }
     
     class func isSandboxCertificate(_ certificate: NWCertificateRef) -> Bool {
     return self.environment(forCertificate: certificate) == NWEnvironmentSandbox
     }
     
     class func environment(forIdentity identity: NWIdentityRef) -> NWEnvironment {
     var certificate: NWCertificateRef? = try? self.certificate(withIdentity: identity)
     return self.environment(forCertificate: certificate)
     }
     
     class func environment(forCertificate certificate: NWCertificateRef) -> NWEnvironment {
     switch self.type(withCertificate: certificate, summary: nil) {
     case kNWCertTypeIOSDevelopment, kNWCertTypeMacDevelopment:
     return NWEnvironmentSandbox
     case kNWCertTypeIOSProduction, kNWCertTypeMacProduction:
     return NWEnvironmentProduction
     case kNWCertTypeSimplified, kNWCertTypeWebProduction, kNWCertTypeVoIPServices, kNWCertTypeWatchKitServices, kNWCertTypeNone, kNWCertTypeUnknown:
     break
     }
     
     return NWEnvironmentNone
     }
     
     // MARK: - Initialization
     // MARK: - Inspection
     
     class func type(withCertificate certificate: NWCertificateRef, summary: String) -> NWCertType {
     if summary != "" {
     summary = nil
     }
     var name: String = self.plainSummary(withCertificate: certificate)
     for t in kNWCertTypeNone..<kNWCertTypeUnknown {
     var prefix: String = self.prefix(withCertType: t)
     if prefix && name.hasPrefix(prefix) {
     if summary != "" {
     summary = (name as? NSString)?.substring(from: (prefix.characters.count ?? 0))
     }
     return t
     }
     }
     if summary != "" {
     summary = name
     }
     return kNWCertTypeUnknown
     }
     
     class func prefix(with type: NWCertType) -> String {
     switch type {
     case kNWCertTypeIOSDevelopment:
     return "Apple Development IOS Push Services: "
     case kNWCertTypeIOSProduction:
     return "Apple Production IOS Push Services: "
     case kNWCertTypeMacDevelopment:
     return "Apple Development Mac Push Services: "
     case kNWCertTypeMacProduction:
     return "Apple Production Mac Push Services: "
     case kNWCertTypeSimplified:
     return "Apple Push Services: "
     case kNWCertTypeWebProduction:
     return "Website Push ID: "
     case kNWCertTypeVoIPServices:
     return "VoIP Services: "
     case kNWCertTypeWatchKitServices:
     return "WatchKit Services: "
     case kNWCertTypeNone, kNWCertTypeUnknown:
     break
     }
     
     return nil
     }
     // MARK: - Sec wrappers
     
     class func plainSummary(withCertificate certificate: NWCertificateRef) -> String {
     return certificate ? CFBridgingRelease(SecCertificateCopySubjectSummary((certificate as? SecCertificateRef))) : nil!
     }
     
     class func derData(withCertificate certificate: NWCertificateRef) -> Data {
     return certificate ? CFBridgingRelease(SecCertificateCopyData((certificate as? SecCertificateRef))) : nil!
     }*/
    
    class func allIdentities(withPKCS12Data data: Data, password: String) throws -> [[String : Any]]? {
        var items: CFArray?
        var result = [[String : Any]]()
        try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
            if let cfdata = CFDataCreate(kCFAllocatorDefault, bytes, data.count) {
                let options : [String : String] = [kSecImportExportPassphrase as String : password]
                print("options: \(options)")
                let status = SecPKCS12Import(cfdata, options as CFDictionary, &items)
                if status != errSecSuccess || items == nil {
                    throw NWError.PKCS12Error(status)
                }
                result = items as! [[String : Any]]
                /*print("result[0]: \(result[0])")
                let fItem = result[0]
                print("fItem: \(fItem)")
                let identity = fItem["identity"]
                print("identity: \(identity)")*/
                //result = itemsArray
                /*print("CFGetTypeID(fItem): \(CFGetTypeID(fItem as CFTypeRef!))")
                //let cfDic = [:] as CFDictionary
                print("CFArrayGetTypeID(): \(CFArrayGetTypeID())")
                print("CFDictionaryGetTypeID(): \(CFDictionaryGetTypeID())")
                print("CFStringGetTypeID(): \(CFStringGetTypeID())")*/
                /*for i in 0..<CFArrayGetCount(items)  {
                    if let pItem = CFArrayGetValueAtIndex(items, i)  {
                        let dic = pItem.bindMemory(to: CFDictionary.self, capacity: MemoryLayout<CFDictionary>.size) //as! CFDictionary
                        var theDic = dic as! [String : Any]
                        /*let dicCount = CFDictionaryGetCount(dic)
                        let keys = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: MemoryLayout<UnsafeRawPointer>.size * dicCount)
                        let values = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: MemoryLayout<UnsafeRawPointer>.size * dicCount)
                        defer {
                            keys.deinitialize()
                            keys.deallocate(capacity: MemoryLayout<UnsafeRawPointer>.size * dicCount)
                            values.deinitialize()
                            values.deallocate(capacity: MemoryLayout<UnsafeRawPointer>.size * dicCount)
                        }
                        CFDictionaryGetKeysAndValues(dic, keys, values)
                        for j in 0..<dicCount {
                            if let cKey = CFStringGetCStringPtr(keys[i] as! CFString, CFStringBuiltInEncodings.UTF8.rawValue) {
                                let theKey = String(cString: cKey)
                                let theValue = values[j] as Any
                                theDic[theKey] = theValue
                            }
                        }*/
                        result.append(theDic)
                    }
                }*/
            }
        }
        return result
    }
}
