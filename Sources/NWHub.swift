//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWHub.swift
//  Pusher
//
//  Copyright (c) 2014 noodlewerk. All rights reserved.
//
import Foundation

/** Allows callback on errors while pushing to and reading from server. 
 
 Check out `NWHub` for more details.
 */
protocol NWHubDelegate: NSObjectProtocol {
    /** The notification failed during or after pushing. */
    func notification(_ notification: NWNotification, didFailWithError error: Error?)
}
/** Helper on top of `NWPusher` that hides the details of pushing and reading.
 
 This class provides a more convenient way of pushing notifications to the APNs. It deals with the trouble of assigning a unique identifier to every notification and the handling of error responses from the server. It hides the latency that comes with transmitting the pushes, allowing you to simply push your notifications and getting notified of errors through the delegate. If this feels over-abstracted, then definitely check out the `NWPusher` class, which will give you full control.
 
 There are two set of methods for pushing notifications: the easy and the pros. The former will just do the pushing and reconnect if the connection breaks. This is your low-worry solution, provided that you call `readFailed` every so often (seconds) to handle error data from the server. The latter will give you a little more control and a little more responsibility.
 */
class NWHub: NSObject {
    /** @name Properties */
    /** The pusher instance that does the actual work. */
    var pusher: NWPusher!
    /** Assign a delegate to get notified when something fails during or after pushing. */
    weak var delegate: NWHubDelegate?
    /** The type of notification serialization we'll be using. */
    var type = NWNotificationType()
    /** The timespan we'll hold on to a notification after pushing, allowing the server to respond. */
    var feedbackSpan = TimeInterval()
    /** The index incremented on every notification push, used as notification identifier. */
    var index: Int = 0
    /** @name Initialization */
    /** Create and return a hub object with a delegate object assigned. */

    convenience init(delegate: NWHubDelegate) {
        return self.init(NWPusher(), delegate: delegate)
    }
    /** Create and return a hub object with a delegate and pusher object assigned. */

    override init(pusher: NWPusher, delegate: NWHubDelegate) {
        super.init()
        
        self.index = 1
        self.feedbackSpan = 30
        self.pusher = pusher
        self.delegate = delegate
        self.notificationForIdentifier = [:]
        self.type = kNWNotificationType2
    
    }
    /** Create, connect and returns an instance with delegate and identity. */

    class func connect(with delegate: NWHubDelegate, identity: NWIdentityRef, environment: NWEnvironment, error: Error?) -> Self {
        var hub = NWHub(delegate: delegate)
        return identity && (try? hub.connect(withIdentity: identity, environment: environment)) ? hub : nil!
    }
    /** Create, connect and returns an instance with delegate and identity. */

    class func connect(with delegate: NWHubDelegate, pkcs12Data data: Data, password: String, environment: NWEnvironment, error: Error?) -> Self {
        var hub = NWHub(delegate: delegate)
        return data && (try? hub.connect(withPKCS12Data: data, password: password, environment: environment)) ? hub : nil!
    }
    /** @name Connecting */
    /** Connect the pusher using the identity to setup the SSL connection. */

    func connect(withIdentity identity: NWIdentityRef, environment: NWEnvironment) throws {
        return try? self.pusher.connect(withIdentity: identity, environment: environment)!
    }
    /** Connect the pusher using the PKCS #12 data to setup the SSL connection. */

    func connect(withPKCS12Data data: Data, password: String, environment: NWEnvironment) throws {
        return try? self.pusher.connect(withPKCS12Data: data, password: password, environment: environment)!
    }
    /** Reconnect with the server, to recover from a closed or defect connection. */

    func reconnect() throws {
        return try? self.pusher.reconnect()!
    }
    /** Close the connection, allows reconnecting. */

    override func disconnect() {
        self.pusher.disconnect()
    }
    /** @name Pushing (easy) */
    /** Push a JSON string payload to a device with token string.
     @see pushNotifications:
     */

    func pushPayload(_ payload: String, token: String) -> Int {
        var notification = NWNotification(payload: payload, token: token, identifier: 0, expiration: nil, priority: 0)
        return self.pushNotifications([notification])
    }
    /** Push a JSON string payload to multiple devices with token strings.
     @see pushNotifications:
     */

    func pushPayload(_ payload: String, tokens: [Any]) -> Int {
        var notifications: [Any] = []
        for token: String in tokens {
            var notification = NWNotification(payload: payload, token: token, identifier: 0, expiration: nil, priority: 0)
            notifications.append(notification)
        }
        return self.pushNotifications(notifications)
    }
    /** Push multiple JSON string payloads to a device with token string.
     @see pushNotifications:
     */

    func pushPayloads(_ payloads: [Any], token: String) -> Int {
        var notifications: [Any] = []
        for payload: String in payloads {
            var notification = NWNotification(payload: payload, token: token, identifier: 0, expiration: nil, priority: 0)
            notifications.append(notification)
        }
        return self.pushNotifications(notifications)
    }
    /** Push multiple notifications, each representing a payload and a device token.
     
     This will assign each notification a unique identifier if none was set yet. If pushing fails it will reconnect. This method can be used rather carelessly; any thing goes. However, this also means that a failed notification might break the connection temporarily, losing a notification here or there. If you are sending bulk and don't care too much about this, then you'll be fine. If not, consider using `pushNotification:autoReconnect:error:`.
     
     Make sure to call `readFailed` on a regular basis to allow server error responses to be handled and the delegate to be called.
     
     Returns the number of notifications that failed, preferably zero.
     
     @see readFailed
     */

    func pushNotifications(_ notifications: [Any]) -> Int {
        var fails: Int = 0
        for notification: NWNotification in notifications {
            var success: Bool? = try? self.push(notification, autoReconnect: true)
            if success == nil {
                fails += 1
            }
        }
        return fails
    }
    /** Read the response from the server to see if any pushes have failed.
     
     Due to transmission latency it usually takes a couple of milliseconds for the server to respond to errors. This methods reads the server response and handles the errors. Make sure to call this regularly to catch up on malformed notifications.
     
     @see pushNotifications:
     */

    func readFailed() -> Int {
        var failed: [Any]? = nil
        try? self.readFailed(failed, max: 1000, autoReconnect: true)
        return failed?.count!
    }
    /** @name Pushing (pros) */
    /** Push a notification and reconnect if anything failed. 
     
     This will assign the notification a unique (incremental) identifier and feed it to the internal pusher. If this succeeds, the notification is stored for later lookup by `readFailed:autoReconnect:error:`. If it fails, the delegate will be invoked and it will reconnect if set to auto-reconnect.
     
     @see readFailed:autoReconnect:error:
     */

    func push(_ notification: NWNotification, autoReconnect reconnect: Bool) throws {
        if !notification.identifier {
            notification.identifier = self.index += 1
        }
        var e: Error? = nil
        var pushed: Bool? = try? self.pusher.push(notification, type: self.type)
        if pushed == nil {
            if error != nil {
                error = e
            }
            if self.delegate.responds(to: Selector("notification:didFailWithError:")) {
                self.delegate.notification(notification, didFailWithError: e)
            }
            if reconnect && e?.code == kNWErrorWriteClosedGraceful {
                try? self.reconnect()
            }
            return pushed!
        }
        self.notificationForIdentifier[(notification.identifier)] = [notification, Date()]
        return true
    }
    /** Read the response from the server and reconnect if anything failed.
     
     If the APNs finds something wrong with a notification, it will write back the identifier and error code. As this involves transmission to and from the server, it takes just a little while to get this failure info. This method should therefore be invoked a little (say a second) after pushing to see if anything was wrong. On a slow connection this might take longer than the interval between push messages, in which case the reported notification was *not* the last one sent.
     
     From the server we only get the notification identifier and the error message. This method translates this back into the original notification by keeping track of all notifications sent in the past 30 seconds. If somehow the original notification cannot be found, it will assign `NSNull`.
     
     Usually, when a notification fails, the server will drop the connection. To prevent this from causing any more problems, the connection can be reestablished by setting it to reconnect automatically.
     
     @see trimIdentifiers
     @see feedbackSpan
     */

    func readFailed(_ notification: NWNotification, autoReconnect reconnect: Bool) throws {
        var identifier: Int = 0
        var apnError: Error? = nil
        var read: Bool? = try? self.pusher.readFailedIdentifier(identifier, apnError: apnError)
        if read == nil {
            return read!
        }
        if apnError != nil {
            var n: NWNotification? = self.notificationForIdentifier[(identifier)][0]
            if notification {
                notification = n ?? (NSNull() as? NWNotification)
            }
            if self.delegate.responds(to: Selector("notification:didFailWithError:")) {
                self.delegate.notification(n, didFailWithError: apnError)
            }
            if reconnect {
                try? self.reconnect()
            }
        }
        return true
    }
    /** Let go of old notification, after you read the failed notifications.
     
     This class keeps track of all notifications sent so we can look them up later based on their identifier. This allows it to translate identifiers back into the original notification. To limit the amount of memory all older notifications should be trimmed from this lookup, which is done by this method. This is done based on the `feedbackSpan`, which defaults to 30 seconds.
     
     Be careful not to call this function without first reading all failed notifications, using `readFailed:autoReconnect:error:`.
     
     @see readFailed:autoReconnect:error:
     @see feedbackSpan
     */

    func trimIdentifiers() -> Bool {
        var oldBefore = Date(timeIntervalSinceNow: -self.feedbackSpan)
        var old: [Any] = Array(self.notificationForIdentifier.keysOfEntries(passingTest: {(_ key: Any, _ obj: Any, _ stop: Bool) -> BOOL in
                return oldBefore.compare(obj[1]) == .orderedDescending
            }))
        for k in old { self.notificationForIdentifier.removeValueForKey(k) }
        return !!old.count
    }
    // deprecated

    class func connect(with delegate: NWHubDelegate, identity: NWIdentityRef, error: Error?) -> Self {
        return try? self.connect(with: delegate, identity: identity, environment: NWEnvironmentAuto)!
    }

    class func connect(with delegate: NWHubDelegate, pkcs12Data data: Data, password: String, error: Error?) -> Self {
        return try? self.connect(with: delegate, identity: data, environment: NWEnvironmentAuto)!
    }

    func connect(withIdentity identity: NWIdentityRef) throws {
        return try? self.connect(withIdentity: identity, environment: NWEnvironmentAuto)!
    }

    func connect(withPKCS12Data data: Data, password: String) throws {
        return try? self.connect(withPKCS12Data: data, password: password, environment: NWEnvironmentAuto)!
    }
    var notificationForIdentifier = [AnyHashable: Any]()



    convenience override init() {
        return self.init(NWPusher(), delegate: nil)
    }
// MARK: - Connecting
// MARK: - Pushing without NSError
// MARK: - Pushing with NSError

    func pushNotifications(_ notifications: [Any], autoReconnect reconnect: Bool) throws {
        for notification: NWNotification in notifications {
            var success: Bool? = try? self.push(notification, autoReconnect: reconnect)
            if success == nil {
                return success!
            }
        }
        return true
    }
// MARK: - Reading failed

    func readFailed(_ notifications: [Any], max: Int, autoReconnect reconnect: Bool) throws {
        var n: [Any] = []
        for i in 0..<max {
            var notification: NWNotification? = nil
            var read: Bool? = try? self.readFailed(notification, autoReconnect: reconnect)
            if read == nil {
                return read!
            }
            if notification == nil {
                break
            }
            n.append(notification)
        }
        if !notifications.isEmpty {
            notifications = n
        }
        self.trimIdentifiers()
        return true
    }
// MARK: - Deprecated
}