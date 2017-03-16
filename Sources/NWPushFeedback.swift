//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWPushFeedback.swift
//  Pusher
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//
//  Modified by: Amr Aboelela on 3/16/17.
//

import Foundation

/** Reads tokens and dates from the APNs feedback service.
 
 The feedback service is a separate server that provides a list of all device tokens that it tried to deliver a notification to, but was unable to. This usually indicates that this device no longer has the app installed. This way, the feedback service provides reliable way of finding out who uninstalled the app, which can be fed back into your database.
 
 Apple recommends reading from the service once a day. After a device token has been read, it will not be returned again until the next failed delivery. In practice: connect once a day, read all device tokens, and update your own database accordingly.
 
 Read more in Apple's documentation under *The Feedback Service*.
 */
class NWPushFeedback: NSObject {
    /** @name Properties */
    var connection: NWSSLConnection!
    /** @name Initialization */
    /** Setup connection with feedback service based on identity. */

    class func connect(withIdentity identity: NWIdentityRef, environment: NWEnvironment, error: Error?) -> Self {
        var feedback = NWPushFeedback()
        return identity && (try? feedback.connect(withIdentity: identity, environment: environment)) ? feedback : nil!
    }
    /** Setup connection with feedback service based on PKCS #12 data. */

    class func connect(withPKCS12Data data: Data, password: String, environment: NWEnvironment, error: Error?) -> Self {
        var feedback = NWPushFeedback()
        return data && (try? feedback.connect(withPKCS12Data: data, password: password, environment: environment)) ? feedback : nil!
    }
    /** @name Connecting */
    /** Connect with feedback service based on identity. */

    func connect(withIdentity identity: NWIdentityRef, environment: NWEnvironment, error: Error?) -> Bool {
        if self.connection {
            self.connection.disconnect()
        }
        self.connection = nil
        if environment == NWEnvironmentAuto {
            environment = NWSecTools.environment(forIdentity: identity)
        }
        var host: String = (environment == NWEnvironmentSandbox) ? NWSandboxPushHost : NWPushHost
        var connection = NWSSLConnection(host: host, port: NWPushPort, identity: identity)
        var connected: Bool? = try? connection.connect()
        if connected == nil {
            return connected!
        }
        self.connection = connection
        return true
    }
    /** Connect with feedback service based on PKCS #12 data. */

    func connect(withPKCS12Data data: Data, password: String, environment: NWEnvironment, error: Error?) -> Bool {
        var identity: NWIdentityRef? = try? NWSecTools.identity(withPKCS12Data: data, password: password)
        if identity == nil {
            return false
        }
        return try? self.connect(withIdentity: identity, environment: environment)!
    }
    /** Disconnect from feedback service. The server will automatically drop the connection after all feedback data has been read. */

    override func disconnect() {
        self.connection.disconnect()
        self.connection = nil
    }
    /** @name Reading */
    /** Read a single token-date pair, where token is data. */

    func readTokenData(_ token: Data, date: Date) throws {
        token = nil
        date = nil
        var data = Data(length: MemoryLayout<UInt32>.size + MemoryLayout<UInt16>.size + NWTokenMaxSize)
        var length: Int = 0
        var read: Bool? = try? self.connection.read(data, length: length)
        if !read || length == 0 {
            return read!
        }
        if length != data.length {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorFeedbackLength, reason: length)!
        }
        var time: UInt32 = 0
        data.getBytes(time, range: NSRange(location: 0, length: 4))
        date = Date(timeIntervalSince1970: htonl(time))
        var l: UInt16 = 0
        data.getBytes(l, range: NSRange(location: 4, length: 2))
        var tokenLength: Int = htons(l)
        if tokenLength != NWTokenMaxSize {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorFeedbackTokenLength, reason: tokenLength)!
        }
        token = data.subdata(with: NSRange(location: 6, length: length - 6))
        return true
    }
    /** Read a single token-date pair, where token is hex string. */

    func readToken(_ token: String, date: Date) throws {
        token = nil
        var data: Data? = nil
        var read: Bool? = try? self.readTokenData(data, date: date)
        if read == nil {
            return read!
        }
        if data != nil {
            token = NWNotification.hex(from: data)
        }
        return true
    }
    /** Read all (or max) token-date pairs, where token is hex string. */

    func readTokenDatePairs(withMax max: Int, error: Error?) -> [Any] {
        var pairs: [Any] = []
        for i in 0..<max {
            var token: String? = nil
            var date: Date? = nil
            var e: Error? = nil
            var read: Bool? = try? self.readToken(token, date: date)
            if !read && e?.code == kNWErrorReadClosedGraceful {
                break
            }
            if read == nil {
                if error != nil {
                    error = e
                }
                return nil
            }
            if token && date {
                pairs.append([token, date])
            }
        }
        return pairs
    }
    // deprecated

    class func connect(withIdentity identity: NWIdentityRef, error: Error?) -> Self {
        return try? self.connect(withIdentity: identity, environment: NWEnvironmentAuto)!
    }

    class func connect(withPKCS12Data data: Data, password: String, error: Error?) -> Self {
        return try? self.connect(withPKCS12Data: data, password: password, environment: NWEnvironmentAuto)!
    }

    func connect(withIdentity identity: NWIdentityRef, error: Error?) -> Bool {
        return try? self.connect(withIdentity: identity, environment: NWEnvironmentAuto)!
    }

    func connect(withPKCS12Data data: Data, password: String, error: Error?) -> Bool {
        return try? self.connect(withPKCS12Data: data, password: password, environment: NWEnvironmentAuto)!
    }

// MARK: - Connecting
// MARK: - Reading feedback
// MARK: - Deprecated
}
let NWSandboxPushHost: String = "feedback.sandbox.push.apple.com"

let NWPushHost: String = "feedback.push.apple.com"

let NWPushPort: Int = 2196

let NWTokenMaxSize: Int = 32
