//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWType.swift
//  Pusher
//
//  Copyright (c) 2014 noodlewerk. All rights reserved.
//
import Foundation
/** The current and past data formats supported by APNs. For more information see Apple documentation under 'Legacy Information'. */
enum NWNotificationType : Int {
    /** The 'Simple Notification Format'. The oldest format, simply concatenates the device token and payload. */
    case kNWNotificationType0 = 0
    /** The 'Enhanced Notification Format'. Similar to the previous format, but includes and identifier and expiration date. */
    case kNWNotificationType1 = 1
    /** The 'Binary Interface and Notification Format'. The latest, more extensible format that allows for attributes like priority. */
    case kNWNotificationType2 = 2
}

/** An ARC-friendly replacement of SecIdentityRef. */
typealias NWIdentityRef = Any
/** An ARC-friendly replacement of SecCertificateRef. */
typealias NWCertificateRef = Any
/** An ARC-friendly replacement of SecKeyRef. */
typealias NWKeyRef = Any
/** List all error codes. */
enum NWError : Int {
    /** No error, that's odd. */
    case kNWErrorNone = 0
    /** APN processing error. */
    case kNWErrorAPNProcessing = -1
    /** APN missing device token. */
    case kNWErrorAPNMissingDeviceToken = -2
    /** APN missing topic. */
    case kNWErrorAPNMissingTopic = -3
    /** APN missing payload. */
    case kNWErrorAPNMissingPayload = -4
    /** APN invalid token size. */
    case kNWErrorAPNInvalidTokenSize = -5
    /** APN invalid topic size. */
    case kNWErrorAPNInvalidTopicSize = -6
    /** APN invalid payload size. */
    case kNWErrorAPNInvalidPayloadSize = -7
    /** APN invalid token. */
    case kNWErrorAPNInvalidTokenContent = -8
    /** APN unknown reason. */
    case kNWErrorAPNUnknownReason = -9
    /** APN shutdown. */
    case kNWErrorAPNShutdown = -10
    /** APN unknown error code. */
    case kNWErrorAPNUnknownErrorCode = -11
    /** Push response command unknown. */
    case kNWErrorPushResponseCommand = -107
    /** Push reconnect requires connection. */
    case kNWErrorPushNotConnected = -111
    /** Push not fully sent. */
    case kNWErrorPushWriteFail = -112
    /** Feedback data length unexpected. */
    case kNWErrorFeedbackLength = -108
    /** Feedback token length unexpected. */
    case kNWErrorFeedbackTokenLength = -109
    /** Socket cannot be created. */
    case kNWErrorSocketCreate = -222
    /** Socket connecting failed. */
    case kNWErrorSocketConnect = -201
    /** Socket host cannot be resolved. */
    case kNWErrorSocketResolveHostName = -219
    /** Socket file control failed. */
    case kNWErrorSocketFileControl = -220
    /** Socket options cannot be set. */
    case kNWErrorSocketOptions = -221
    /** SSL connection cannot be set. */
    case kNWErrorSSLConnection = -204
    /** SSL context cannot be created. */
    case kNWErrorSSLContext = -202
    /** SSL callbacks cannot be set. */
    case kNWErrorSSLIOFuncs = -203
    /** SSL peer domain name cannot be set. */
    case kNWErrorSSLPeerDomainName = -205
    /** SSL certificate cannot be set. */
    case kNWErrorSSLCertificate = -206
    /** SSL handshake dropped by server. */
    case kNWErrorSSLDroppedByServer = -207
    /** SSL handshake authentication failed. */
    case kNWErrorSSLAuthFailed = -208
    /** SSL handshake failed. */
    case kNWErrorSSLHandshakeFail = -209
    /** SSL handshake root not a known anchor. */
    case kNWErrorSSLHandshakeUnknownRootCert = -223
    /** SSL handshake chain not verifiable to root. */
    case kNWErrorSSLHandshakeNoRootCert = -224
    /** SSL handshake expired certificates. */
    case kNWErrorSSLHandshakeCertExpired = -225
    /** SSL handshake invalid certificate chain. */
    case kNWErrorSSLHandshakeXCertChainInvalid = -226
    /** SSL handshake expecting client cert. */
    case kNWErrorSSLHandshakeClientCertRequested = -227
    /** SSL handshake auth interrupted. */
    case kNWErrorSSLHandshakeServerAuthCompleted = -228
    /** SSL handshake certificate expired. */
    case kNWErrorSSLHandshakePeerCertExpired = -229
    /** SSL handshake certificate revoked. */
    case kNWErrorSSLHandshakePeerCertRevoked = -230
    /** SSL handshake certificate unknown. */
    case kNWErrorSSLHandshakePeerCertUnknown = -233
    /** SSL handshake internal error. */
    case kNWErrorSSLHandshakeInternalError = -234
    /** SSL handshake in dark wake. */
    case kNWErrorSSLInDarkWake = -231
    /** SSL handshake connection closed via error. */
    case kNWErrorSSLHandshakeClosedAbort = -232
    /** SSL handshake timeout. */
    case kNWErrorSSLHandshakeTimeout = -218
    /** Read connection dropped by server. */
    case kNWErrorReadDroppedByServer = -210
    /** Read connection error. */
    case kNWErrorReadClosedAbort = -211
    /** Read connection closed. */
    case kNWErrorReadClosedGraceful = -212
    /** Read failed. */
    case kNWErrorReadFail = -213
    /** Write connection dropped by server. */
    case kNWErrorWriteDroppedByServer = -214
    /** Write connection error. */
    case kNWErrorWriteClosedAbort = -215
    /** Write connection closed. */
    case kNWErrorWriteClosedGraceful = -216
    /** Write failed. */
    case kNWErrorWriteFail = -217
    /** Identity does not contain certificate. */
    case kNWErrorIdentityCopyCertificate = -304
    /** Identity does not contain private key. */
    case kNWErrorIdentityCopyPrivateKey = -310
    /** PKCS12 data cannot be imported. */
    case kNWErrorPKCS12Import = -306
    /** PKCS12 data is empty. */
    case kNWErrorPKCS12EmptyData = -305
    /** PKCS12 data cannot be read or is malformed. */
    case kNWErrorPKCS12Decode = -311
    /** PKCS12 data password incorrect. */
    case kNWErrorPKCS12AuthFailed = -312
    /** PKCS12 data wrong password. */
    case kNWErrorPKCS12Password = -313
    /** PKCS12 data password required. */
    case kNWErrorPKCS12PasswordRequired = -314
    /** PKCS12 data contains no identities. */
    case kNWErrorPKCS12NoItems = -307
    /** PKCS12 data contains multiple identities. */
    case kNWErrorPKCS12MultipleItems = -309
    /** Keychain cannot be searched. */
    case kNWErrorKeychainCopyMatching = -401
    /** Keychain does not contain private key. */
    case kNWErrorKeychainItemNotFound = -302
    /** Keychain does not contain certificate. */
    case kNWErrorKeychainCreateIdentity = -303
}

enum NWEnvironment : Int {
    case none = 0
    case sandbox = 1
    case production = 2
    case auto = 3
}

enum NWEnvironmentOptions : Int {
    case nwEnvironmentOptionNone = 0
    static let nwEnvironmentOptionSandbox: NWEnvironmentOptions = 1 << .sandbox
    static let nwEnvironmentOptionProduction: NWEnvironmentOptions = 1 << .production
    static let nwEnvironmentOptionAny: NWEnvironmentOptions = [.nwEnvironmentOptionSandbox, .nwEnvironmentOptionProduction]
}

/** NSError dictionary key for integer code that indicates underlying reason. */
let NWErrorReasonCodeKey: String = ""

/** A collection of helper methods to support Cocoa-style error handling (`NSError`).
 
 Most methods in this framework return `NO` or `nil` to indicate an error occurred. In that case an error object will be assigned. This class provides a mapping from codes to description string and some methods to instantiate the `NSError` object.
 */
/** Returns string for given environment, for logging purposes */
func descriptionForEnvironentOptions(environmentOptions: NWEnvironmentOptions) -> String {
    switch environmentOptions {
        case .nwEnvironmentOptionNone:
            return "No environment"
        case .nwEnvironmentOptionSandbox:
            return "Sandbox"
        case .nwEnvironmentOptionProduction:
            return "Production"
        case .nwEnvironmentOptionAny:
            return "Sandbox|Production"
    }

    return nil
}

func descriptionForEnvironent(environment: NWEnvironment) -> String {
    switch environment {
        case []:
            return "none"
        case .production:
            return "production"
        case .sandbox:
            return "sandbox"
        case .auto:
            return "auto"
    }

    return nil
}

class NWErrorUtil: NSObject {
    /** @name Helpers */
    /** Assigns the error with provided code and associated description, for returning `NO`. */
    class func noWithErrorCode(_ code: NWError) throws {
        return try? self.noWithErrorCode(code, reason: 0)!
    }

    class func noWithErrorCode(_ code: NWError, reason: Int) throws {
        assert(code != .kNWErrorNone, "code != kNWErrorNone")
        if error != nil {
            error = self.errorWithErrorCode(code, reason: reason)
        }
        return false
    }
    /** Assigns the error with provided code and associated description, for returning `nil`. */

    class func nilWithErrorCode(_ code: NWError, error: Error?) -> Any {
        return try? self.nilWithErrorCode(code, reason: 0)!
    }

    class func nilWithErrorCode(_ code: NWError, reason: Int, error: Error?) -> Any {
        assert(code != .kNWErrorNone, "code != kNWErrorNone")
        if error != nil {
            error = self.errorWithErrorCode(code, reason: reason)
        }
        return nil
    }


    class func string(withCode code: NWError) -> String {
        switch code {
            case .kNWErrorNone:
                return "No error, that's odd"
            case .kNWErrorAPNProcessing:
                return "APN processing error"
            case .kNWErrorAPNMissingDeviceToken:
                return "APN missing device token"
            case .kNWErrorAPNMissingTopic:
                return "APN missing topic"
            case .kNWErrorAPNMissingPayload:
                return "APN missing payload"
            case .kNWErrorAPNInvalidTokenSize:
                return "APN invalid token size"
            case .kNWErrorAPNInvalidTopicSize:
                return "APN invalid topic size"
            case .kNWErrorAPNInvalidPayloadSize:
                return "APN invalid payload size"
            case .kNWErrorAPNInvalidTokenContent:
                return "APN invalid token"
            case .kNWErrorAPNUnknownReason:
                return "APN unknown reason"
            case .kNWErrorAPNShutdown:
                return "APN shutdown"
            case .kNWErrorAPNUnknownErrorCode:
                return "APN unknown error code"
            case .kNWErrorPushResponseCommand:
                return "Push response command unknown"
            case .kNWErrorPushNotConnected:
                return "Push reconnect requires connection"
            case .kNWErrorPushWriteFail:
                return "Push not fully sent"
            case .kNWErrorFeedbackLength:
                return "Feedback data length unexpected"
            case .kNWErrorFeedbackTokenLength:
                return "Feedback token length unexpected"
            case .kNWErrorSocketCreate:
                return "Socket cannot be created"
            case .kNWErrorSocketResolveHostName:
                return "Socket host cannot be resolved"
            case .kNWErrorSocketConnect:
                return "Socket connecting failed"
            case .kNWErrorSocketFileControl:
                return "Socket file control failed"
            case .kNWErrorSocketOptions:
                return "Socket options cannot be set"
            case .kNWErrorSSLConnection:
                return "SSL connection cannot be set"
            case .kNWErrorSSLContext:
                return "SSL context cannot be created"
            case .kNWErrorSSLIOFuncs:
                return "SSL callbacks cannot be set"
            case .kNWErrorSSLPeerDomainName:
                return "SSL peer domain name cannot be set"
            case .kNWErrorSSLCertificate:
                return "SSL certificate cannot be set"
            case .kNWErrorSSLDroppedByServer:
                return "SSL handshake dropped by server"
            case .kNWErrorSSLAuthFailed:
                return "SSL handshake authentication failed"
            case .kNWErrorSSLHandshakeFail:
                return "SSL handshake failed"
            case .kNWErrorSSLHandshakeUnknownRootCert:
                return "SSL handshake root not a known anchor"
            case .kNWErrorSSLHandshakeNoRootCert:
                return "SSL handshake chain not verifiable to root"
            case .kNWErrorSSLHandshakeCertExpired:
                return "SSL handshake expired certificates"
            case .kNWErrorSSLHandshakeXCertChainInvalid:
                return "SSL handshake invalid certificate chain"
            case .kNWErrorSSLHandshakeClientCertRequested:
                return "SSL handshake expecting client cert"
            case .kNWErrorSSLHandshakeServerAuthCompleted:
                return "SSL handshake auth interrupted"
            case .kNWErrorSSLHandshakePeerCertExpired:
                return "SSL handshake certificate expired"
            case .kNWErrorSSLHandshakePeerCertRevoked:
                return "SSL handshake certificate revoked"
            case .kNWErrorSSLHandshakePeerCertUnknown:
                return "SSL handshake certificate unknown"
            case .kNWErrorSSLHandshakeInternalError:
                return "SSL handshake internal error"
            case .kNWErrorSSLInDarkWake:
                return "SSL handshake in dark wake"
            case .kNWErrorSSLHandshakeClosedAbort:
                return "SSL handshake connection closed via error"
            case .kNWErrorSSLHandshakeTimeout:
                return "SSL handshake timeout"
            case .kNWErrorReadDroppedByServer:
                return "Read connection dropped by server"
            case .kNWErrorReadClosedAbort:
                return "Read connection error"
            case .kNWErrorReadClosedGraceful:
                return "Read connection closed"
            case .kNWErrorReadFail:
                return "Read failed"
            case .kNWErrorWriteDroppedByServer:
                return "Write connection dropped by server"
            case .kNWErrorWriteClosedAbort:
                return "Write connection error"
            case .kNWErrorWriteClosedGraceful:
                return "Write connection closed"
            case .kNWErrorWriteFail:
                return "Write failed"
            case .kNWErrorIdentityCopyCertificate:
                return "Identity does not contain certificate"
            case .kNWErrorIdentityCopyPrivateKey:
                return "Identity does not contain private key"
            case .kNWErrorPKCS12Import:
                return "PKCS12 data cannot be imported"
            case .kNWErrorPKCS12EmptyData:
                return "PKCS12 data is empty"
            case .kNWErrorPKCS12Decode:
                return "PKCS12 data cannot be read or is malformed"
            case .kNWErrorPKCS12AuthFailed:
                return "PKCS12 data password incorrect"
            case .kNWErrorPKCS12Password:
                return "PKCS12 data wrong password"
            case .kNWErrorPKCS12PasswordRequired:
                return "PKCS12 data password required"
            case .kNWErrorPKCS12NoItems:
                return "PKCS12 data contains no identities"
            case .kNWErrorPKCS12MultipleItems:
                return "PKCS12 data contains multiple identities"
            case .kNWErrorKeychainCopyMatching:
                return "Keychain cannot be searched"
            case .kNWErrorKeychainItemNotFound:
                return "Keychain does not contain private key"
            case .kNWErrorKeychainCreateIdentity:
                return "Keychain does not contain certificate"
        }

        return "Unknown"
    }
// MARK: - Helpers

    class func errorWithErrorCode(_ code: NWError, reason: Int) -> Error? {
        var description: String = self.string(withCode: code)
        if reason != 0 {
            description = "\(description) (\(Int(reason)))"
        }
        var info: [AnyHashable: Any] = [NSLocalizedDescriptionKey: description]
        if reason != 0 {
            info[NWErrorReasonCodeKey] = (reason)
        }
        return Error(domain: "NWPusherErrorDomain", code: code, userInfo: info)
    }
}
let NWErrorReasonCodeKey: String = "NWErrorReasonCodeKey"