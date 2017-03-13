//  Converted with Swiftify v1.0.6276 - https://objectivec2swift.com/
//
//  NWSSLConnection.swift
//  Pusher
//
//  Copyright (c) 2012 noodlewerk. All rights reserved.
//
import Foundation
/** An SSL (TLS) connection to the APNs.

 This class is basically an Objective-C wrapper around `SSLContextRef` and `SSLConnectionRef`, which are part of the native Secure Transport framework. This class provides a generic interface for SSL (TLS) connections, independent of NWPusher.
 
 A SSL connection is set up using the host name, host port and an identity. The host name will be resolved using DNS. The identity is an instance of `SecIdentityRef` and contains both a certificate and a private key. See the *Secure Transport Reference* for more info on that.
 
 Read more about provider communication in Apple's documentation under *Apple Push Notification Service*.
 
 Methods return `NO` if an error occurred.
 */
class NWSSLConnection: NSObject {
    /** @name Properties */
    /** The host name, which will be resolved using DNS. */
    var host: String = ""
    /** The host TCP port number. */
    var port: Int = 0
    /** Identity containing a certificate-key pair for setting up the TLS connection. */
    var identity: NWIdentityRef = nil
    /** @name Initialization */
    /** Initialize a connection parameters host name, port, and identity. */

    override init(host: String, port: Int, identity: NWIdentityRef) {
        super.init()
        
        self.host = host
        self.port = port
        self.identity = identity
        self.socket = -1
    
    }
    /** @name Connecting */
    /** Connect socket, TLS and perform handshake.
     Can also be used when already connected, which will then first disconnect. */

    func connect() throws {
        self.disconnect()
        var socket: Bool? = try? self.connectSocket()
        if socket == nil {
            self.disconnect()
            return socket!
        }
        var ssl: Bool? = try? self.connectSSL()
        if ssl == nil {
            self.disconnect()
            return ssl!
        }
        var handshake: Bool? = try? self.handshakeSSL()
        if handshake == nil {
            self.disconnect()
            return handshake!
        }
        return true
    }
    /** Drop connection if connected. */

    override func disconnect() {
        if self.context {
            SSLClose(self.context)
        }
        if self.socket >= 0 {
            close(self.socket)
        }
        self.socket = -1
        if self.context {

        }
        self.context = nil
    }
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
    /** Write length number of bytes from data object. */

    func write(_ data: Data, length: Int) throws {
        length = 0
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

        return try? NWErrorUtil.noWithErrorCode(kNWErrorWriteFail, reason: status)!
    }
    var socket: Int = 0
    var context: SSLContextRef = nil



    convenience override init() {
        return self.init(host: nil, port: 0, identity: nil)
    }

    deinit {
        self.disconnect()
    }
// MARK: - Connecting

    func connectSocket() throws {
        var sock: Int = socket(AF_INET, SOCK_STREAM, 0)
        if sock < 0 {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSocketCreate, reason: sock)!
        }
struct sockaddr_in {
}

        var addr: sockaddr_in
        memset(addr, 0, MemoryLayout<sockaddr_in>.size)
struct hostent {
}

        var entr: hostent? = gethostbyname(self.host.utf8)
        if entr == nil {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSocketResolveHostName)!
        }
struct in_addr {
}

        var host: in_addr
        memcpy(host, entr?.h_addr, MemoryLayout<in_addr>.size)
        addr.sin_addr = host
        addr.sin_port = htons((self.port as? u_short))
        addr.sin_family = AF_INET
        var conn: Int? = connect(sock, (addr as? sockaddr), MemoryLayout<sockaddr_in>.size)
        if conn < 0 {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSocketConnect, reason: conn)!
        }
        var cntl: Int = fcntl(sock, F_SETFL, O_NONBLOCK)
        if cntl < 0 {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSocketFileControl, reason: cntl)!
        }
        var set: Int = 1
        var sopt: Int? = setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, (set as? Void), MemoryLayout<Int>.size)
        if sopt < 0 {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSocketOptions, reason: sopt)!
        }
        self.socket = sock
        return true
    }

    func connectSSL() throws {
        var context: SSLContextRef = SSLCreateContext(nil, kSSLClientSide, kSSLStreamType)
        if context == nil {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLContext)!
        }
        var setio: OSStatus = SSLSetIOFuncs(context, NWSSLRead, NWSSLWrite)
        if setio != errSecSuccess {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLIOFuncs, reason: setio)!
        }
        var setconn: OSStatus? = SSLSetConnection(context, (Int(self.socket) as? SSLConnectionRef))
        if setconn != errSecSuccess {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLConnection, reason: setconn)!
        }
        var setpeer: OSStatus = SSLSetPeerDomainName(context, self.host.utf8, strlen(self.host.utf8))
        if setpeer != errSecSuccess {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLPeerDomainName, reason: setpeer)!
        }
        var setcert: OSStatus? = SSLSetCertificate(context, ([self.identity] as? CFArrayRef))
        if setcert != errSecSuccess {
            return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLCertificate, reason: setcert)!
        }
        self.context = context
        return true
    }

    func handshakeSSL() throws {
        var status: OSStatus = errSSLWouldBlock
        var i = 0
        while i < NWSSL_HANDSHAKE_TRY_COUNT && status == errSSLWouldBlock {
            status = SSLHandshake(self.context)
            i += 1
        }
        switch status {
            case errSecSuccess:
                return true
            case errSSLWouldBlock:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeTimeout)!
            case errSecIO:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLDroppedByServer)!
            case errSecAuthFailed:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLAuthFailed)!
            case errSSLUnknownRootCert:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeUnknownRootCert)!
            case errSSLNoRootCert:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeNoRootCert)!
            case errSSLCertExpired:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeCertExpired)!
            case errSSLXCertChainInvalid:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeXCertChainInvalid)!
            case errSSLClientCertRequested:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeClientCertRequested)!
            case errSSLServerAuthCompleted:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeServerAuthCompleted)!
            case errSSLPeerCertExpired:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakePeerCertExpired)!
            case errSSLPeerCertRevoked:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakePeerCertRevoked)!
            case errSSLPeerCertUnknown:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakePeerCertUnknown)!
            case errSSLInternal:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeInternalError)!
#if !TARGET_OS_IPHONE
            case errSecInDarkWake:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLInDarkWake)!
#endif
            case errSSLClosedAbort:
                return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeClosedAbort)!
        }

        return try? NWErrorUtil.noWithErrorCode(kNWErrorSSLHandshakeFail, reason: status)!
    }
// MARK: - Read Write
}
let NWSSL_HANDSHAKE_TRY_COUNT = 1 << 26
func NWSSLRead(connection: SSLConnectionRef, data: Void, length: size_t) -> OSStatus {
    var leng: size_t = length
    length = 0
    var read: size_t = 0
    var rcvd: ssize_t = 0
    
    while read < leng {
        rcvd = recv(Int(connection), CChar(data) + read, leng - read, 0)
        if rcvd <= 0 {
            break
        }
        read += rcvd
    }
    length = read
    if rcvd > 0 || !leng {
        return errSecSuccess
    }
    if !rcvd {
        return errSSLClosedGraceful
    }
    switch errno {
        case EAGAIN:
            return errSSLWouldBlock
        case ECONNRESET:
            return errSSLClosedAbort
    }

    return errSecIO
}

func NWSSLWrite(connection: SSLConnectionRef, data: Void, length: size_t) -> OSStatus {
    var leng: size_t = length
    length = 0
    var sent: size_t = 0
    var wrtn: ssize_t = 0
    
    while sent < leng {
        wrtn = write(Int(connection), CChar(data) + sent, leng - sent)
        if wrtn <= 0 {
            break
        }
        sent += wrtn
    }
    length = sent
    if wrtn > 0 || !leng {
        return errSecSuccess
    }
    switch errno {
        case EAGAIN:
            return errSSLWouldBlock
        case EPIPE:
            return errSSLClosedAbort
    }

    return errSecIO
}