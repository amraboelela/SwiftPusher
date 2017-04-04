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

enum NWError: Error {
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
    case resolveHostNameError
    case pushResponseWithCommand(Int)
}
