//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWSSLConnection.swift
//  Pusher
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//
import Foundation

extension String {
    
    public var cString: UnsafeMutablePointer<Int8> {
        return UnsafeMutablePointer<Int8>(mutating: NSString(string: self).utf8String)!
    }
}

func htons(_ value: CUnsignedShort) -> CUnsignedShort {
    return value.bigEndian
}

/** An SSL (TLS) connection to the APNs.

 This class is basically an Objective-C wrapper around `SSLContextRef` and `SSLConnectionRef`, which are part of the native Secure Transport framework. This class provides a generic interface for SSL (TLS) connections, independent of NWPusher.
 
 A SSL connection is set up using the host name, host port and an identity. The host name will be resolved using DNS. The identity is an instance of `SecIdentityRef` and contains both a certificate and a private key. See the *Secure Transport Reference* for more info on that.
 
 Read more about provider communication in Apple's documentation under *Apple Push Notification Service*.
 
 Methods return `NO` if an error occurred.
 */
class NWSSLConnection {
    /** @name Properties */
    /** The host name, which will be resolved using DNS. */
    var host = ""
    /** The host TCP port number. */
    var port = 0
    /** Identity containing a certificate-key pair for setting up the TLS connection. */
    var identity: SecIdentity?
    var socket: CFSocketNativeHandle
    var pSocket: UnsafeMutablePointer<CFSocketNativeHandle>?
    var context: SSLContext?
    
    /** @name Initialization */
    /** Initialize a connection parameters host name, port, and identity. */
    init(host: String, port: Int, identity: SecIdentity) {
        self.host = host
        self.port = port
        self.identity = identity
        self.socket = -1
    }
    
    // MARK: Static methods
    
    
    /** @name Connecting */
    /** Connect socket, TLS and perform handshake.
     Can also be used when already connected, which will then first disconnect. */
    func connect() throws {
        self.disconnect()
        do {
            pSocket = UnsafeMutablePointer<CFSocketNativeHandle>.allocate(capacity: MemoryLayout<CFSocketNativeHandle>.size)
            try self.connectSocket()
            try self.connectSSL()
            try self.handshakeSSL()
        } catch {
            self.disconnect()
            throw error
        }
    }
    
    /** Drop connection if connected. */
    func disconnect() {
        if let context = context {
            SSLClose(context)
        }
        if self.socket >= 0 {
            close(self.socket)
        }
        self.socket = -1
        self.context = nil
        pSocket?.deinitialize()
        pSocket?.deallocate(capacity: MemoryLayout<CFSocketNativeHandle>.size)
        pSocket = nil
    }
    
    /*
    /** @name I/O */
    /** Read length number of bytes into mutable data object. */
    func read(_ data: Data, length: Int) throws {
        length = 0
        var processed: size_t = 0
        var status: OSStatus = SSLRead(self.context, data.mutableBytes, data.length, processed)
        length = processed
        switch status {
            case errSecSuccess:
                return true
            case errSSLWouldBlock:
                return true
            case errSecIO:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorReadDroppedByServer)!
            case errSSLClosedAbort:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorReadClosedAbort)!
            case errSSLClosedGraceful:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorReadClosedGraceful)!
        }

        return try? NWErrorUtil.noWithErrorCode(kNWErrorReadFail, reason: status)!
    }
     */
    
    /** Write length number of bytes from data object. */
    func write(_ data: Data, length: Int) throws {
        /*length = 0
        var processed: size_t = 0
        var status: OSStatus = SSLWrite(self.context, data.bytes, data.length, processed)
        length = processed
        switch status {
            case errSecSuccess:
                return true
            case errSSLWouldBlock:
                return true
            case errSecIO:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorWriteDroppedByServer)!
            case errSSLClosedAbort:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorWriteClosedAbort)!
            case errSSLClosedGraceful:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorWriteClosedGraceful)!
        }

        return try? NWErrorUtil.noWithErrorCode(kNWErrorWriteFail, reason: status)!*/
    }
    
    /*
    convenience init() {
        self.init(host: "", port: 0, identity: nil)
    }*/

    deinit {
        self.disconnect()
    }
    
    // MARK: - Connecting

    func connectSocket() throws {
        
        var flags = AI_PASSIVE | AI_CANONNAME
        var hints = addrinfo()
        hints.ai_family = PF_UNSPEC
        #if os(OSX) || os(iOS) || os(Android)
            hints.ai_socktype = SOCK_STREAM
        #else
            hints.ai_socktype = Int32(SOCK_STREAM.rawValue)
        #endif
        
        hints.ai_flags = flags
        
        var addressInfo: UnsafeMutablePointer<addrinfo>? = nil
        let r = getaddrinfo(host, nil, &hints, &addressInfo)
        defer {
            freeaddrinfo(addressInfo)
        }
        if r != 0 {
            throw NWError.socketConnectionFailed
        }
        let pHost = UnsafeMutablePointer<Int8>.allocate(capacity: Int(NI_MAXHOST))
        var hostAddress = ""
        defer {
            pHost.deinitialize()
            pHost.deallocate(capacity: Int(NI_MAXHOST))
        }
        let info = addressInfo!.pointee
        let family = info.ai_family
        if family != AF_INET && family != AF_INET6 {
            throw NWError.socketConnectionFailed
        }
        let sa_len: socklen_t = socklen_t((family == AF_INET6) ? MemoryLayout<sockaddr_in6>.size : MemoryLayout<sockaddr_in>.size)
        if getnameinfo(info.ai_addr, sa_len, pHost, socklen_t(NI_MAXHOST), nil, 0, flags) == 0 {
            hostAddress = String(cString: pHost)
        } else {
            throw NWError.socketConnectionFailed
        }
        
        if family == AF_INET {
            #if os(Linux)
                let myipv4cfsock = CFSocketCreate(kCFAllocatorDefault, PF_INET, Int32(SOCK_STREAM.rawValue), Int32(IPPROTO_TCP), CFOptionFlags(kCFSocketNoCallBack), nil, nil)
            #else
                let myipv4cfsock = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, nil, nil)
            #endif
            let sinSize = MemoryLayout<sockaddr_in>.size
            let sin = UnsafeMutablePointer<sockaddr_in>.allocate(capacity: sinSize)
            defer {
                sin.deinitialize()
                sin.deallocate(capacity: sinSize)
            }
            memset(sin, 0, sinSize)
            sin.pointee.sin_family = sa_family_t(UInt16(AF_INET))
            sin.pointee.sin_port = htons(UInt16(port))
            sin.pointee.sin_addr.s_addr = inet_addr(hostAddress)
            
            try sin.withMemoryRebound(to: UInt8.self, capacity: sinSize, {
                let sincfd = CFDataCreate(kCFAllocatorDefault, $0, sinSize)
                let socketError = CFSocketConnectToAddress(myipv4cfsock, sincfd, 0)
                #if os(Linux)
                    if socketError != 0 {
                        throw NWError.socketConnectionFailed
                    }
                #else
                    if socketError.rawValue != 0 {
                        throw NWError.socketConnectionFailed
                    }
                #endif
            })
            self.socket = CFSocketGetNative(myipv4cfsock)
            pSocket?.pointee = self.socket
            // Make non blocking
            let flags = fcntl(socket, F_GETFL)
            _ = fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        } else {
            throw NWError.socketConnectionFailed
        }
    }

    func connectSSL() throws {
        guard let context = SSLCreateContext(nil, .clientSide, .streamType) else {
            throw NWError.SSLContextCannotBeCreated
        }
        if SSLSetIOFuncs(context, NWSSLRead, NWSSLWrite) != errSecSuccess {
            throw NWError.SSLCallbacksCannotBeSet
        }
        if SSLSetConnection(context, SSLConnectionRef(pSocket)) != errSecSuccess {
            throw NWError.SSLConnectionCannotBeSet
        }
        if SSLSetPeerDomainName(context, self.host.cString, self.host.length) != errSecSuccess {
            throw NWError.SSLPeerDomainName
        }
        if SSLSetCertificate(context, [self.identity] as? CFArray) != errSecSuccess {
            throw NWError.SSLCertificate
        }
        self.context = context
    }
    
    func handshakeSSL() throws {
        guard let context = context else {
            throw NWError.SSLContextCannotBeCreated
        }
        var status = errSSLWouldBlock
        var i = 0
        let NWSSL_HANDSHAKE_TRY_COUNT = 1 << 26
        while i < NWSSL_HANDSHAKE_TRY_COUNT && status == errSSLWouldBlock {
            status = SSLHandshake(context)
            i += 1
        }
        switch status {
        case errSecSuccess:
            return
        case errSSLWouldBlock:
            throw NWError.SSLHandshakeTimeout
        case errSecIO:
            throw NWError.SSLDroppedByServer
        case errSecAuthFailed:
            throw NWError.SSLAuthFailed
        case errSSLUnknownRootCert:
            throw NWError.SSLHandshakeUnknownRootCert
        case errSSLNoRootCert:
            throw NWError.SSLHandshakeNoRootCert
        case errSSLCertExpired:
            throw NWError.SSLHandshakeCertExpired
        case errSSLXCertChainInvalid:
            throw NWError.SSLHandshakeXCertChainInvalid
        case errSSLClientCertRequested:
            throw NWError.SSLHandshakeClientCertRequested
        case errSSLPeerCertExpired:
            throw NWError.SSLHandshakePeerCertExpired
        case errSSLPeerCertRevoked:
            throw NWError.SSLHandshakePeerCertRevoked
        case errSSLPeerCertUnknown:
            throw NWError.SSLHandshakePeerCertUnknown
        case errSSLInternal:
            throw NWError.SSLHandshakeInternalError
        case errSSLClosedAbort:
            throw NWError.SSLHandshakeClosedAbort
        default:
            throw NWError.SSLHandshakeFail
        }
    }
}

// MARK: - Read Write

func NWSSLRead(connection: SSLConnectionRef, data: UnsafeMutableRawPointer, length: UnsafeMutablePointer<Int>) -> OSStatus {
    var leng = length.pointee
    length.pointee = 0
    var read = 0
    var rcvd = 0
    let socket = connection.bindMemory(to: CFSocketNativeHandle.self, capacity: MemoryLayout<CFSocketNativeHandle>.size).pointee
    while read < leng {
        rcvd = recv(socket, data + read, leng - read, 0)
        if rcvd <= 0 {
            break
        }
        read += rcvd
    }
    length.pointee = read
    if rcvd > 0 || leng==0 {
        return errSecSuccess
    }
    if rcvd==0 {
        return errSSLClosedGraceful
    }
    switch errno {
    case EAGAIN:
        return errSSLWouldBlock
    case ECONNRESET:
        return errSSLClosedAbort
    default:
        return errSecIO
    }
}

func NWSSLWrite(connection: SSLConnectionRef, data: UnsafeRawPointer, length: UnsafeMutablePointer<Int>) -> OSStatus {
    var leng = length.pointee
    length.pointee = 0
    var sent = 0
    var wrtn = 0
    let socket = connection.bindMemory(to: CFSocketNativeHandle.self, capacity: MemoryLayout<CFSocketNativeHandle>.size).pointee
    while sent < leng {
        wrtn = write(socket, data + sent, leng - sent)
        if wrtn <= 0 {
            break
        }
        sent += wrtn
    }
    length.pointee = sent
    if wrtn > 0 || length.pointee==0 {
        return errSecSuccess
    }
    switch errno {
    case EAGAIN:
        return errSSLWouldBlock
    case EPIPE:
        return errSSLClosedAbort
    default:
        return errSecIO
    }
}
 
