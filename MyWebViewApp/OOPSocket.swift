//
//  OOPSocket.swift
//  MyWebViewApp
//
//  Created by 開発 on 2017/3/21.
//  Copyright © 2017 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

// A simple wrapper of CFSocket
public class OOPSocket {
    public struct ProtocolFamily: RawRepresentable {
        public let rawValue: Int32
        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static let inet = ProtocolFamily(PF_INET)
        public static let inet6 = ProtocolFamily(PF_INET6)
    }
    
    public struct InetProtocol: RawRepresentable {
        public let rawValue: Int32
        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let tcp = InetProtocol(IPPROTO_TCP)
    }
    
    public struct AddressFamily: RawRepresentable {
        public let rawValue: Int32
        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public static let inet = AddressFamily(AF_INET)
        public static let inet6 = AddressFamily(AF_INET6)
        
        public init(_ family: sa_family_t) {
            self.init(Int32(family))
        }
    }
    
    public enum SocketAddress {
        case inet(sockaddr_in)
        case inet6(sockaddr_in6)
        
        public init(_ saddr: UnsafePointer<sockaddr>) {
            if saddr.pointee.sa_family == sa_family_t(AF_INET) {
                self = saddr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {ipv4saddr in
                    .inet(ipv4saddr.pointee)
                }
            } else if saddr.pointee.sa_family == sa_family_t(AF_INET6) {
                self = saddr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) {ipv6saddr in
                    .inet6(ipv6saddr.pointee)
                }
            } else {
                fatalError("Invalaid sa_family")
            }
        }
        
        public init(_ addr: InetAddress, _ port: in_port_t) {
            switch addr {
            case .inet(let ipv4addr):
                var ipv4saddr = sockaddr_in()
                ipv4saddr.sin_len = UInt8(MemoryLayout<sockaddr_in>.stride)
                ipv4saddr.sin_family = sa_family_t(AF_INET)
                ipv4saddr.sin_port = port.bigEndian
                ipv4saddr.sin_addr = ipv4addr
                self = .inet(ipv4saddr)
            case .inet6(let ipv6addr):
                var ipv6saddr = sockaddr_in6()
                ipv6saddr.sin6_len = UInt8(MemoryLayout<sockaddr_in>.stride)
                ipv6saddr.sin6_family = sa_family_t(AF_INET6)
                ipv6saddr.sin6_port = port.bigEndian
                ipv6saddr.sin6_addr = ipv6addr
                self = .inet6(ipv6saddr)
            }
        }
        
        internal var data: Data {
            switch self {
            case .inet(var ipv4saddr):
                let ipv4data = Data(bytes: &ipv4saddr, count: MemoryLayout<sockaddr_in>.stride)
                return ipv4data
            case .inet6(var ipv6saddr):
                let ipv6data = Data(bytes: &ipv6saddr, count: MemoryLayout<sockaddr_in6>.stride)
                return ipv6data
            }
        }
        
        internal init(data: Data) {
            self = data.withUnsafeBytes {sockaddrBytes in
                .init(sockaddrBytes.bindMemory(to: sockaddr.self).baseAddress!)
            }
        }
        
        var port: in_port_t {
            switch self {
            case .inet(let ipv4saddr):
                return UInt16(bigEndian: ipv4saddr.sin_port)
            case .inet6(let ipv6saddr):
                return UInt16(bigEndian: ipv6saddr.sin6_port)
            }
        }
    }
    
    public enum InetAddress: ExpressibleByStringLiteral, CustomStringConvertible {
        case inet(in_addr)
        case inet6(in6_addr)
        
        public init(unicodeScalarLiteral value: UnicodeScalar) {
            fatalError("Invalid InetAddress")
        }
        
        public init(extendedGraphemeClusterLiteral value: Character) {
            fatalError("Invalid InetAddress")
        }
        
        public init(stringLiteral value: String) {
            self.init(value)
        }
        
        public init(_ string: String) {
            var result: Int32 = 0
            if string.contains(".") {
                var ipv4iaddr = in_addr()
                result = inet_pton(AF_INET, string, &ipv4iaddr)
                if result == 1 {
                    self = .inet(ipv4iaddr)
                    return
                }
            } else if string.contains(":") {
                var ipv6iaddr = in6_addr()
                result = inet_pton(AF_INET6, string, &ipv6iaddr)
                if result == 1 {
                    self = .inet6(ipv6iaddr)
                    return
                }
            }
            fatalError("Invalid InetAddress")
        }
        
        public var description: String {
            var buf: [Int8] = Array(repeating: 0, count: Int(INET6_ADDRSTRLEN))
            switch self {
            case .inet(var ipv4iaddr):
                inet_ntop(AF_INET, &ipv4iaddr, &buf, socklen_t(buf.count))
            case .inet6(var ipv6iaddr):
                inet_ntop(AF_INET6, &ipv6iaddr, &buf, socklen_t(buf.count))
            }
            return String(cString: buf)
        }
    }
    
    private var cfSocket: CFSocket!
    
    public typealias AcceptHandler = (OOPSocket, SocketAddress, InputStream, OutputStream)->Void
    private var acceptHandler: AcceptHandler?
    
    public init(forListening protocolFamily: ProtocolFamily, _ inetProtocol: InetProtocol, acceptHandler: @escaping AcceptHandler) {
        self.acceptHandler = acceptHandler
        var context = CFSocketContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()
        cfSocket = CFSocketCreate(nil, protocolFamily.rawValue, SOCK_STREAM, inetProtocol.rawValue, CFSocketCallBackType.acceptCallBack.rawValue, acceptCallBack, &context)
    }
    
    private let acceptCallBack: CFSocketCallBack = { s, type, address, data, info in
        assert(type == CFSocketCallBackType.acceptCallBack)
        let sockAddr = SocketAddress(data: address! as Data)
        let nativeHandle = data!.load(as: CFSocketNativeHandle.self)
        var umReadStream: Unmanaged<CFReadStream>?
        var umWriteStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocket(nil, nativeHandle, &umReadStream, &umWriteStream)
        let inputStream = umReadStream!.takeUnretainedValue() as InputStream
        let outputStream = umWriteStream!.takeUnretainedValue() as OutputStream
        CFReadStreamSetProperty(inputStream as CFReadStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket) , kCFBooleanTrue)
        CFWriteStreamSetProperty(outputStream as CFWriteStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanTrue)
        let mySelf = Unmanaged<OOPSocket>.fromOpaque(info!).takeUnretainedValue()
        mySelf.acceptHandler?(mySelf, sockAddr, inputStream, outputStream)
    }
    
    public func listen(_ sockAddr: SocketAddress) throws {
        let err = CFSocketSetAddress(cfSocket, sockAddr.data as CFData)
        guard err == .success else {
            throw err
        }
        let socketsource = CFSocketCreateRunLoopSource(nil, cfSocket, 0)
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            socketsource,
            .defaultMode)
    }
    
    public var socketAddress: SocketAddress? {
        let addr = CFSocketCopyAddress(cfSocket)
        return addr.map{SocketAddress(data: $0 as Data)}
    }
    
    public func invalidate() {
        CFSocketInvalidate(cfSocket)
    }
}

extension CFSocketError: Error {}
