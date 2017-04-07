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
public class NWPushFeedback: NWPusher {

    public typealias TokenHandler = ([String], Error?) -> Void
    static let tokenMaxSize = 32
    
    // MARK: Life cycle
    
    override init() {
        super.init()
        sandboxHost = "feedback.sandbox.push.apple.com"
        productionHost = "feedback.push.apple.com"
        port = 2196
    }
    
    /** @name Reading */
    
    /** Read a single token-date pair, where token is data. */
    public func read(callback: @escaping TokenHandler) {
        var tokens = [String]()
        let lPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: MemoryLayout<UInt16>.size)
        defer {
            lPointer.deinitialize()
            lPointer.deallocate(capacity: MemoryLayout<UInt16>.size)
        }
        let tokenPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: NWPushFeedback.tokenMaxSize)
        defer {
            tokenPointer.deinitialize()
            tokenPointer.deallocate(capacity: NWPushFeedback.tokenMaxSize)
        }
        while true {
            var data = Data(count: MemoryLayout<UInt32>.size + MemoryLayout<UInt16>.size + NWPushFeedback.tokenMaxSize)
            do {
                var length = 0
                try self.connection.read(data, length: &length)
                if length==0 {
                    callback(tokens, nil)
                    return
                }
                if length != data.count {
                    callback(tokens, NWError.feedbackLengthError)
                    return
                }
            } catch {
                callback(tokens, error)
                return
            }

            data.copyBytes(to: lPointer, from: 4..<6)
            var l: UInt16 = 0
            lPointer.withMemoryRebound(to: UInt16.self, capacity: MemoryLayout<UInt16>.size, {
                l = $0.pointee
            })
            let tokenLength = Int(htonl(CUnsignedInt(l)))
            if tokenLength == 0 {
                callback(tokens, nil)
                return
            }
            if tokenLength != NWPushFeedback.tokenMaxSize {
                callback(tokens, NWError.feedbackTokenLengthError)
                return
            }

            data.copyBytes(to: tokenPointer, from: 6..<6+NWPushFeedback.tokenMaxSize)
            
            var tokenData = Data()
            tokenData.append(tokenPointer, count: tokenLength)
            tokens.append(NWNotification.hex(from: tokenData))
        }
    }
}
