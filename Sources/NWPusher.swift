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
    
    static let sandboxPushHost = "gateway.sandbox.push.apple.com"
    static let productionPushHost = "gateway.push.apple.com"
    static let pushPort = 2195
    
    /** @name Properties */
    /** The SSL connection through which all notifications are pushed. */
    var connection: NWSSLConnection!
    /** @name Initialization */
    
    /*
    /** Creates, connects and returns a pusher object based on the provided identity. */
    class func connect(withIdentity identity: NWIdentityRef, environment: NWEnvironment, error: Error?) throws -> NWPusher? {
        var pusher = NWPusher()
        if identity && try pusher.connect(withIdentity: identity, environment: environment) {
            return pusher
        }
    }*/
    
    /** Creates, connects and returns a pusher object based on the PKCS #12 data. */
    public class func connect(withPKCS12Data data: Data, password: String, isSandbox: Bool) throws -> NWPusher? {
        var pusher = NWPusher()
        return try pusher.connect(withPKCS12Data: data, password: password, isSandbox: isSandbox) ? pusher : nil
    }
    
    /** @name Connecting */
    /** Connect with the APNs using the identity. */
    func connect(withIdentity identity: SecIdentity, isSandbox: Bool) throws -> Bool {
        if (self.connection != nil) {
            //self.connection.disconnect()
        }
        self.connection = nil
        let host = isSandbox ? NWPusher.sandboxPushHost : NWPusher.productionPushHost
        var connection = NWSSLConnection(host: host, port: NWPusher.pushPort, identity: identity)
        var connected: Bool? = try? connection.connect()
        if connected == nil {
            return connected!
        }
        self.connection = connection
        return true
    }
 
    /** Connect with the APNs using the identity from PKCS #12 data. */
    func connect(withPKCS12Data data: Data, password: String, isSandbox: Bool) throws -> Bool {
        if let identity = try NWSecTools.identity(withPKCS12Data: data, password: password) {
            return try self.connect(withIdentity: identity, isSandbox: isSandbox)
        }
        return false
    }
    
    /*
    /** Reconnect using the same identity, disconnects if necessary. */
    func reconnect() throws {
        if !self.connection {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorPushNotConnected)!
        }
        return try? self.connection.connect()!
    }
    /** Disconnect from the server, allows reconnect. */

    override func disconnect() {
        self.connection.disconnect()
        self.connection = nil
    }
    /** @name Pushing */
    /** Push a JSON string payload to a device with token string, assign identifier. */

    func pushPayload(_ payload: String, token: String, identifier: Int) throws {
        return try? self.pushNotification(NWNotification(payload: payload, token: token, identifier: identifier, expiration: nil, priority: 0), type: kNWNotificationType2)!
    }
    /** Push a notification using push type for serialization. */

    func push(_ notification: NWNotification, type: NWNotificationType) throws {
        var length: Int = 0
        var data: Data? = notification.data(with: type)
        var written: Bool? = try? self.connection.write(data, length: length)
        if written == nil {
            return written!
        }
        if length != data?.length {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorPushWriteFail, reason: length)!
        }
        return true
    }
    /** @name Reading */
    /** Read back from the server the notification identifiers of failed pushes. */

    func readFailedIdentifier(_ identifier: Int, apnError: Error?) throws {
        identifier = 0
        var data = Data(length: MemoryLayout<UInt8>.size * 2 + MemoryLayout<UInt32>.size)
        var length: Int = 0
        var read: Bool? = try? self.connection.read(data, length: length)
        if !length || !read {
            return read!
        }
        var command: UInt8 = 0
        data.getBytes(command, range: NSRange(location: 0, length: 1))
        if command != 8 {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorPushResponseCommand, reason: command)!
        }
        var status: UInt8 = 0
        data.getBytes(status, range: NSRange(location: 1, length: 1))
        var ID: UInt32 = 0
        data.getBytes(ID, range: NSRange(location: 2, length: 4))
        identifier = htonl(ID)
        switch status {
            case 1:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNProcessing)
            case 2:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNMissingDeviceToken)
            case 3:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNMissingTopic)
            case 4:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNMissingPayload)
            case 5:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNInvalidTokenSize)
            case 6:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNInvalidTopicSize)
            case 7:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNInvalidPayloadSize)
            case 8:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNInvalidTokenContent)
            case 10:
                try? NWErrorUtil.noWithErrorCode(kNWErrorAPNShutdown)
            default:
                try? NWErrorUtil.noWith(kNWErrorAPNUnknownErrorCode, reason: status)
        }

        return true
    }
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
    }
    // deprecated

    class func connect(withIdentity identity: NWIdentityRef, error: Error?) -> Self {
        return try? self.connect(withIdentity: identity, environment: NWEnvironmentAuto)!
    }

    class func connect(withPKCS12Data data: Data, password: String, isSandbox: Bool) throws -> NWPusher? {
        return try self.connect(withPKCS12Data: data, password: password, environment: NWEnvironmentAuto)
    }
    
    func connect(withIdentity identity: NWIdentityRef, error: Error?) -> Bool {
        return try? self.connect(withIdentity: identity, environment: NWEnvironmentAuto)!
    }

    func connect(withPKCS12Data data: Data, password: String, error: Error?) -> Bool {
        return try? self.connect(withPKCS12Data: data, password: password, environment: NWEnvironmentAuto)!
    }*/

// MARK: - Connecting
// MARK: - Pushing payload
// MARK: - Reading failed
// MARK: - Deprecated
    
}

