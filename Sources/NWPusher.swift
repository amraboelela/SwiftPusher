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

func DLog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
        NSLog("[\(NSString(string: filename).lastPathComponent):\(line)] \(function) - \(message)")
    #endif
}

func ALog(_ message: String, filename: String = #file, function: String = #function, line: Int = #line) {
    NSLog("[\(NSString(string: filename).lastPathComponent):\(line)] \(function) - \(message)")
}

public let nwpusher = NWPusher()

/** Serializes notification objects and pushes them to the APNs.
 
 This is the heart of the framework. As the (inconvenient) name suggest, it's also one of the first classes that was added to the framework. This class provides a straightforward interface to the APNs, including connecting, pushing to and reading from the server.
 
 Connecting is done based on an identity or PKCS #12 data. The identity is an instance of `SecIdentityRef` and contains a certificate and private key. The PKCS #12 data can be deserialized into such an identity. One can reconnect or disconnect at any time, and should if the connection has been dropped by the server. The latter can happen quite easily, for example when there is something wrong with the device token or payload of the notification.
 
 Notifications are pushed one at a time. It is serialized and sent over the wire. If the server then concludes there is something wrong with that notification, it will write back error data. If you send out multiple notifications in a row, these errors might not match up. Therefore every error contains the identifier of the erroneous notification.
 
 Make sure to read this error data from the server, so you can lookup the notification that caused it and prevent the issue in the future. As mentioned earlier, the server easily drops the connection if there is something out of the ordinary. NB: if you read right after pushing, it is very unlikely that data about that push already got back from the server.
 
 Make sure to read Apple's documentation on *Apple Push Notification Service* and *Provider Communication*.
 */
public class NWPusher {
    
    public typealias NWNotificationHandler = (NWNotification?, Error?) -> Void
    
    var sandboxHost: String
    var productionHost: String
    var port: Int
    
    /** @name Properties */
    /** The SSL connection through which all notifications are pushed. */
    var connection: NWSSLConnection!
    var PKCS12Data: Data!
    var password: String!
    var isSandbox: Bool!
    
    // MARK: Life cycle
    
    init() {
        sandboxHost = "gateway.sandbox.push.apple.com"
        productionHost = "gateway.push.apple.com"
        port = 2195
    }
    
    public convenience init(PKCS12Data data: Data, password: String, isSandbox: Bool) {
        self.init()
        PKCS12Data = data
        self.password = password
        self.isSandbox = isSandbox
    }
    
    // MARK: Accessors
    
    public var isOpen: Bool {
        return connection.socket != -1
    }
    
    // MARK: - Connecting
    
    public func connect() throws {
        try connect(withPKCS12Data: PKCS12Data, password: password, isSandbox: isSandbox)
    }
    
    /** Connect with the APNs using the identity. */
    func connect(withIdentity identity: SecIdentity, isSandbox: Bool) throws {
        if (self.connection != nil) {
            self.connection.disconnect()
        }
        self.connection = nil
        let host = isSandbox ? sandboxHost : productionHost
        let connection = NWSSLConnection(host: host, port: port, identity: identity)
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
        let notification = NWNotification(payload: payload, token: token)
        var length = 0
        let data = notification.data()
        notification.status = .sent
        do {
            ALog("before self.connection.write")
            try self.connection.write(data, length: &length)
            ALog("after self.connection.write")
            if length != data.count {
                ALog("length != data.count")
                callback(nil, NWError.pushWriteFail)
            }
        } catch {
            ALog("error: \(error)")
            callback(nil, error)
        }
        self.readFailedIdentifier(callback:callback)
    }
    
    /** Read back from the server the notification identifiers of failed pushes. */
    func readFailedIdentifier(callback:NWNotificationHandler) {
        ALog("1")
        var data = Data(count: MemoryLayout<UInt8>.size * 2 + MemoryLayout<UInt32>.size)
        do {
            var length = 0
            try self.connection.read(data, length: &length)
            if length==0 {
                callback(nil, nil)
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
}
