//
//  File.swift
//  KeychainDemoTests
//
//  Created by Alexander Cyon on 2023-10-06.
//

import Foundation

extension Data {
	static func random(byteCount: Int) -> Data {
		var randomNumberGenerator = SecRandomNumberGenerator()
		return Data((0 ..< byteCount).map { _ in UInt8.random(in: UInt8.min ... UInt8.max, using: &randomNumberGenerator) })
	}
}
struct SecRandomNumberGenerator: RandomNumberGenerator {
	func next() -> UInt64 {
		var bytes: UInt64 = 0
		let result = withUnsafeMutableBytes(of: &bytes, { buffer in
			SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
		})
		
		guard result == errSecSuccess else {
			// Figure out how you'd prefer to deal with this.
			fatalError()
		}
		
		return bytes
	}
}

