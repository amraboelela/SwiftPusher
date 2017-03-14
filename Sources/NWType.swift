//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWType.swift
//  Pusher
//
//  Copyright (c) 2014 noodlewerk. All rights reserved.
//
//  Modified by: Amr Aboelela on 3/13/17.
//

import Foundation

/*
/** The current and past data formats supported by APNs. For more information see Apple documentation under 'Legacy Information'. */
enum NWNotificationType : Int {
    /** The 'Simple Notification Format'. The oldest format, simply concatenates the device token and payload. */
    case kNWNotificationType0 = 0
    /** The 'Enhanced Notification Format'. Similar to the previous format, but includes and identifier and expiration date. */
    case kNWNotificationType1 = 1
    /** The 'Binary Interface and Notification Format'. The latest, more extensible format that allows for attributes like priority. */
    case kNWNotificationType2 = 2
}*/

/** An ARC-friendly replacement of SecIdentityRef. */
typealias NWIdentityRef = Any

/*
/** An ARC-friendly replacement of SecCertificateRef. */
typealias NWCertificateRef = Any
/** An ARC-friendly replacement of SecKeyRef. */
typealias NWKeyRef = Any
/** List all error codes. */
*/

enum NWError: Swift.Error {
    /** No error, that's odd. */
    case none
    /** APN processing error. */
    case processingError
    /** APN missing device token. */
    case missingDeviceToken
    /** APN missing topic. */
    case missingTopic
    /** APN missing payload. */
    case missingPayload
    /** APN invalid token size. */
    case invalidTokenSize
    /** APN invalid topic size. */
    case invalidTopicSize
    /** APN invalid payload size. */
    case invalidPayloadSize
    /** APN invalid token. */
    case invalidTokenContent
    /** APN unknown reason. */
    case unknownReason
    /** APN shutdown. */
    case serverShutdown
    /** APN unknown error code. */
    case unknownError
    /** Push response command unknown. */
    case responseCommandUnkown
    /** Push reconnect requires connection. */
    case reconnectRequiresConnection
    /** Push not fully sent. */
    case pushWriteFail
    /** Feedback data length unexpected. */
    case feedbackLengthError
    /** Feedback token length unexpected. */
    case feedbackTokenLengthError
    /** Socket cannot be created. */
    case socketCreationError
    /** Socket connecting failed. */
    case socketConnectionFailed
    /** Socket host cannot be resolved. */
    case socketHostCannotBeResolved
    /** Socket file control failed. */
    case socketFileControlFailed
    /** Socket options cannot be set. */
    case socketOptionsCannotBeSet
    /** SSL connection cannot be set. */
    case SSLConnectionCannotBeSet
    /** SSL context cannot be created. */
    case SSLContextCannotBeCreated
    /** SSL callbacks cannot be set. */
    case SSLCallbacksCannotBeSet
    /** SSL peer domain name cannot be set. */
    case SSLPeerDomainName
    /** SSL certificate cannot be set. */
    case SSLCertificate
    /** SSL handshake dropped by server. */
    case SSLDroppedByServer
    /** SSL handshake authentication failed. */
    case SSLAuthFailed
    /** SSL handshake failed. */
    case SSLHandshakeFail
    /** SSL handshake root not a known anchor. */
    case SSLHandshakeUnknownRootCert
    /** SSL handshake chain not verifiable to root. */
    case SSLHandshakeNoRootCert
    /** SSL handshake expired certificates. */
    case SSLHandshakeCertExpired
    /** SSL handshake invalid certificate chain. */
    case SSLHandshakeXCertChainInvalid
    /** SSL handshake expecting client cert. */
    case SSLHandshakeClientCertRequested
    /** SSL handshake auth interrupted. */
    case SSLHandshakeServerAuthCompleted
    /** SSL handshake certificate expired. */
    case SSLHandshakePeerCertExpired
    /** SSL handshake certificate revoked. */
    case SSLHandshakePeerCertRevoked
    /** SSL handshake certificate unknown. */
    case SSLHandshakePeerCertUnknown
    /** SSL handshake internal error. */
    case SSLHandshakeInternalError
    /** SSL handshake in dark wake. */
    case SSLInDarkWake
    /** SSL handshake connection closed via error. */
    case SSLHandshakeClosedAbort
    /** SSL handshake timeout. */
    case SSLHandshakeTimeout
    /** Read connection dropped by server. */
    case readDroppedByServer
    /** Read connection error. */
    case readClosedAbort
    /** Read connection closed. */
    case readClosedGraceful
    /** Read failed. */
    case readFail
    /** Write connection dropped by server. */
    case writeDroppedByServer
    /** Write connection error. */
    case writeClosedAbort
    /** Write connection closed. */
    case writeClosedGraceful
    /** Write failed. */
    case writeFail
    /** Identity does not contain certificate. */
    case identityCopyCertificate
    /** Identity does not contain private key. */
    case identityCopyPrivateKey
    
    case PKCS12Error(OSStatus)
    /** PKCS12 data cannot be imported. */
    case PKCS12Import
    /** PKCS12 data is empty. */
    case PKCS12EmptyData
    /** PKCS12 data cannot be read or is malformed. */
    case PKCS12Decode
    /** PKCS12 data password incorrect. */
    case PKCS12AuthFailed
    /** PKCS12 data wrong password. */
    case PKCS12Password
    /** PKCS12 data password required. */
    case PKCS12PasswordRequired
    /** PKCS12 data contains no identities. */
    case PKCS12NoItems
    /** PKCS12 data contains multiple identities. */
    case PKCS12MultipleItems
    /** Keychain cannot be searched. */
    case KeychainCopyMatching
    /** Keychain does not contain private key. */
    case KeychainItemNotFound
    /** Keychain does not contain certificate. */
    case KeychainCreateIdentity
}

/*
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
 */
