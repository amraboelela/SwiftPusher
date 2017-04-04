//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWPusher.swift
//  Pusher
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//
//  Modified by: Amr Aboelela on 3/13/17.
//

import Foundation

/** Serializes notification objects and pushes them to the APNs.
 
 This is the heart of the framework. As the (inconvenient) name suggest, it's also one of the first classes that was added to the framework. This class provides a straightforward interface to the APNs, including connecting, pushing to and reading from the server.
 
 Connecting is done based on an identity or PKCS #12 data. The identity is an instance of `SecIdentityRef` and contains a certificate and private key. The PKCS #12 data can be deserialized into such an identity. One can reconnect or disconnect at any time, and should if the connection has been dropped by the server. The latter can happen quite easily, for example when there is something wrong with the device token or payload of the notification.
 
 Notifications are pushed one at a time. It is serialized and sent over the wire. If the server then concludes there is something wrong with that notification, it will write back error data. If you send out multiple notifications in a row, these errors might not match up. Therefore every error contains the identifier of the erroneous notification.
 
 Make sure to read this error data from the server, so you can lookup the notification that caused it and prevent the issue in the future. As mentioned earlier, the server easily drops the connection if there is something out of the ordinary. NB: if you read right after pushing, it is very unlikely that data about that push already got back from the server.
 
 Make sure to read Apple's documentation on *Apple Push Notification Service* and *Provider Communication*.
 */
public class NWPusher {
    
    public typealias NWNotificationHandler = (NWNotification?, Error?) -> Void
    
    static let sandboxPushHost = "gateway.sandbox.push.apple.com"
    static let productionPushHost = "gateway.push.apple.com"
    static let pushPort = 2195
    
    var notificationClosure: NWNotificationHandler?
    
    /** @name Properties */
    /** The SSL connection through which all notifications are pushed. */
    var connection: NWSSLConnection!
    /** @name Initialization */
    
    /** Creates, connects and returns a pusher object based on the PKCS #12 data. */
    public class func connect(withPKCS12Data data: Data, password: String, isSandbox: Bool) throws -> NWPusher? {
        let pusher = NWPusher()
        do {
            try pusher.connect(withPKCS12Data: data, password: password, isSandbox: isSandbox)
            return pusher
        } catch {
            print("connect error: \(error)")
            return nil
        }
    }
    
    /** @name Connecting */
    /** Connect with the APNs using the identity. */
    func connect(withIdentity identity: SecIdentity, isSandbox: Bool) throws {
        if (self.connection != nil) {
            self.connection.disconnect()
        }
        self.connection = nil
        let host = isSandbox ? NWPusher.sandboxPushHost : NWPusher.productionPushHost
        let connection = NWSSLConnection(host: host, port: NWPusher.pushPort, identity: identity)
        try connection.connect()
        self.connection = connection
        //return connected
    }
 
    /** Connect with the APNs using the identity from PKCS #12 data. */
    func connect(withPKCS12Data data: Data, password: String, isSandbox: Bool) throws {
        if let identity = try NWSecTools.identity(withPKCS12Data: data, password: password) {
            try self.connect(withIdentity: identity, isSandbox: isSandbox)
        }
    }
    
    /** @name Pushing */
    /** Push a JSON string payload to a device with token string, assign identifier. */
    public func send(payload: String, withToken token: String, callback: @escaping NWNotificationHandler) {
        notificationClosure = callback
        let notification = NWNotification(payload: payload, token: token)
        var length = 0
        let data = notification.data()
        notification.status = NWNotificationStatus.sent
        do {
            try self.connection.write(data, length: &length)
            if length != data.count {
                callback(nil, NWError.pushWriteFail)
            }
        } catch {
            callback(nil, error)
        }
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.readFailedIdentifier(callback:callback)
        }
    }
    
    /** Read back from the server the notification identifiers of failed pushes. */
    func readFailedIdentifier(callback:NWNotificationHandler) {
        var data = Data(count: MemoryLayout<UInt8>.size * 2 + MemoryLayout<UInt32>.size)
        do {
            var length = 0
            try self.connection.read(data, length: &length)
            if length==0 {
                callback(nil, NWError.readFail)
                return
            }
        } catch {
            callback(nil, error)
            return
        }
        
        let commandPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer {
            commandPointer.deinitialize()
            commandPointer.deallocate(capacity: 1)
        }
        data.copyBytes(to: commandPointer, count: 1)
        let command = commandPointer.pointee
        
        if command != 8 {
            callback(nil, NWError.pushResponseWithCommand(Int(command)))
            return
        }
        
        let statusPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1)
        defer {
            statusPointer.deinitialize()
            statusPointer.deallocate(capacity: 1)
        }
        data.copyBytes(to: statusPointer, from: 1..<2)
        let status = statusPointer.pointee
        
        let idPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        defer {
            idPointer.deinitialize()
            idPointer.deallocate(capacity: 4)
        }
        data.copyBytes(to: idPointer, from: 2..<6)
        
        var ID: UInt32 = 0
        idPointer.withMemoryRebound(to: UInt32.self, capacity: MemoryLayout<UInt32>.size, {
            ID = $0.pointee
        })
        
        let identifier = Int(htonl(ID))
        if let notification = NWNotification.notifications[identifier] {
            if status == 0 {
                notification.status = .pushed
            } else {
                notification.status = .failed(NWNotificationError(statusCode: Int(status)))
            }
            callback(notification, nil)
        }
    }
    
    /*
    /** Read back multiple notification identifiers of, up to max, failed pushes. */
    func readFailedIdentifierErrorPairs(withMax max: Int, error: Error?) -> [Any] {
        var pairs: [Any] = []
        for i in 0..<max {
            var identifier: Int = 0
            var apnError: Error? = nil
            var read: Bool? = try? self.readFailedIdentifier(identifier, apnError: apnError)
            if read == nil {
                return nil
            }
            if apnError == nil {
                break
            }
            pairs.append([(identifier), apnError])
        }
        return pairs
    }*/
}
