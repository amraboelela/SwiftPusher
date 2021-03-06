//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWNotification.swift
//  Pusher
//
//  Copyright (c) 2014 noodlewerk. All rights reserved.
//
//  Modified by: Amr Aboelela on 3/16/17.
//

import Foundation

extension String {
    
    var length: Int {
        return characters.count
    }
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    var dataFromHexadecimal: Data {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else {
            return Data()
        }
        return data
    }
}

extension Data {
    var hexEncodedString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    var simpleDescription : String {
        if let result = String(data: self, encoding: String.Encoding.utf8) {
            return result
        } else {
            return ""
        }
    }
    
    mutating func appendRawBytes(_ bytes: UnsafeRawPointer, length: Int) {
        self.append(bytes.bindMemory(to: UInt8.self, capacity: length), count: length)
    }
    
    mutating func appendWith(identifier: Int, bytes: UnsafeRawPointer, length: Int) {
        var i = UInt8(identifier)
        var l: UInt16 = htons(UInt16(length))
        self.append(&i, count: 1)
        self.appendRawBytes(&l, length: 2)
        self.appendRawBytes(bytes, length: length)
    }
}

public enum NWNotificationError: Error {
    case APNProcessing
    case APNMissingDeviceToken
    case APNMissingTopic
    case APNMissingPayload
    case APNInvalidTokenSize
    case APNInvalidTopicSize
    case APNInvalidPayloadSize
    case APNInvalidTokenContent
    case APNShutdown
    case APNUnknownErrorCode
    case PushResponseWithCommand(Int)
    
    init(statusCode: Int) {
        switch statusCode {
        case 1:
            self = .APNProcessing
        case 2:
            self = .APNMissingDeviceToken
        case 3:
            self = .APNMissingTopic
        case 4:
            self = .APNMissingPayload
        case 5:
            self = .APNInvalidTokenSize
        case 6:
            self = .APNInvalidTopicSize
        case 7:
            self = .APNInvalidPayloadSize
        case 8:
            self = .APNInvalidTokenContent
        case 10:
            self = .APNShutdown
        default:
            self = .APNUnknownErrorCode
        }
    }
}

enum NWNotificationStatus {
    case created
    case sent
    case pushed
    case failed(Error)
}

/** A single push message, containing the receiver device token, the payload, and delivery attributes.
 
 This class represents a single push message, or *remote notification* as Apple calls it. It consists of device token, payload, and some optional attributes. The device token is a unique reference to a single installed app on a single Apple device. The payload is a JSON-formatted string that is delivered into the app. Among app-specific data, this payload contains information on how the device should handle and display this notification.
 
 Then there is a number of additional attributes Apple has been adding over the years. The *identifier* is used in error data that we get back from the server. This allows us to associate the error with the notification. The *expiration* date tells the delivery system when it should stop trying to deliver the notification to the device. Priority indicates whether to conserve power on delivery.
 
 There are different data formats into which a notification can be serialized. Older formats do not support all attributes. While this class supports all formats, it uses the latest format by default.
 
 Read more about this in Apple's documentation under *Provider Communication with Apple Push Notification Service* and *The Notification Payload*.
 */
public class NWNotification {
    static var notifications:[Int:NWNotification] = [:]
    static var lastIdentifier = 0
    
    var status = NWNotificationStatus.created

    /** @name Properties */
    /** String representation of serialized JSON. */
    var payload: String {
        get {
            return self.payloadData.simpleDescription 
        }
        set {
            self.payloadData = newValue.data(using: String.Encoding.utf8) ?? Data()
        }
    }
    
    /** UTF-8 data representation of serialized JSON. */
    var payloadData = Data()
    
    /** Hex string representation of the device token. */
    var token: String {
        get {
            return NWNotification.hex(from: tokenData)
        }
        set {
            let normal = NWNotification.filterHex(newValue)
            let index64 = normal.index(normal.startIndex, offsetBy: 64)
            let trunk = normal.length >= 64 ? normal.substring(to: index64) : ""
            self.tokenData = NWNotification.data(fromHex: trunk)
        }
    }
    /** Data representation of the device token. */
    var tokenData = Data()
    
    /** Identifier used for correlating server response on error. */
    var identifier = 0
    /** The expiration date after which the server will not attempt to deliver. */
    var expiration: Date? {
        get {
            return isAddExpiration ? Date(timeIntervalSince1970: TimeInterval(expirationStamp)) : nil
        }
        set {
            if let newValue = newValue {
                self.expirationStamp = Int(newValue.timeIntervalSince1970)
                self.isAddExpiration = true
            }
        }
    }
    /** Epoch seconds representation of expiration date. */
    var expirationStamp = 0
    /** Notification priority used by server for delivery optimization. */
    var priority = 0
    /** Indicates whether the expiration date should be serialized. */
    var isAddExpiration = false
    
    /** @name Initialization */
    /** Create and returns a notification object based on given attribute objects. */
    init(payload: String, token: String, expiration date: Date = Date(), priority: Int = 0) {
        
        self.payload = payload
        self.token = token
        NWNotification.lastIdentifier += 1
        self.identifier = NWNotification.lastIdentifier
        NWNotification.notifications[self.identifier] = self
        self.expiration = date
        self.priority = priority
    
    }
    
    /** @name Serialization */
    /** Serialize this notification using provided format. */
    func data() -> Data {
        return self.dataWithType2()
    }
    
    /** @name Helpers */
    /** Converts a hex string into binary data. */
    class func data(fromHex hex: String) -> Data {
        return hex.dataFromHexadecimal
    }
    
    /** Converts binary data into a hex string. */
    class func hex(from data: Data?) -> String {
        return data?.hexEncodedString ?? ""
    }
    
    // MARK: - Helpers

    class func filterHex(_ hex: String) -> String {
        let hexlc = hex.lowercased()
        return hexlc
    }
    
    // MARK: - Types
    
    func dataWithType2() -> Data {
        var result = Data()
        var command = UInt8(2)
        result.append(&command, count: 1)
        var data = Data()
        self.tokenData.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
            data.appendWith(identifier: 1, bytes: bytes, length: self.tokenData.count)
        }
        self.payloadData.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> () in
            data.appendWith(identifier: 2, bytes: bytes, length: self.payloadData.count)
        }
        var identifier = htonl(UInt32(self.identifier))
        var expires = htonl(UInt32(self.expirationStamp))
        var priority = UInt8(self.priority)
        if identifier != 0 {
            data.appendWith(identifier: 3, bytes: &identifier, length: 4)
        }
        if self.isAddExpiration {
            data.appendWith(identifier: 4, bytes: &expires, length: 4)
        }
        if priority != 0 {
            data.appendWith(identifier: 5, bytes: &priority, length: 1)
        }
        var length = htonl(UInt32(data.count))
        result.appendRawBytes(&length, length: 4)
        result.append(data)
        return result
    }
}
