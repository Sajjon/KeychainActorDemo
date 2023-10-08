import Foundation
import KeychainAccess

public final actor KeychainActor: GlobalActor {
	
	private let keychain: Keychain
	private let semaphore = DispatchSemaphore(value: 1)
	private let queue = DispatchQueue(label: "keychainActor", attributes: .concurrent)
	private init() {
		self.keychain = Keychain(service: "MyService")
	}
}

// MARK: Public
extension KeychainActor {
	
	public static let shared = KeychainActor()
	
	public typealias Key = Keychain.Key
	public typealias Label = Keychain.Label
	public typealias Comment = Keychain.Comment
	public typealias AuthenticationPrompt = Keychain.AuthenticationPrompt
}

// MARK: API - No Auth
extension KeychainActor {
	
	func setDataWithoutAuth(
		_ data: Data,
		forKey key: Key,
		with attributes: _KeychainAttributes
	) async throws {
		try await accessingKeychain {
			try $0.modifier(.init(attributes: attributes))
				.set(data, key: key)
		}
	}
	
	func setDataWithoutAuth(
		_ data: Data,
		forKey key: Key,
		label: String? = nil,
		comment: String? = nil,
		isSynchronizable: Bool = false,
		accessibility: Accessibility
	) async throws {
		try await setDataWithoutAuth(
			data,
			forKey: key,
			with: Keychain.AttributesWithoutAuth(
				label: label,
				comment: comment,
				isSynchronizable: isSynchronizable,
				accessibility: accessibility
			)
		)
	}
	
	func getDataWithoutAuth(
		forKey key: Key
	) async throws -> Data? {
		try await accessingKeychain {
			try $0.getData(key)
		}
	}
	
	
	@discardableResult
	func getDataWithoutAuthIfPresent(
		forKey key: Key,
		with attributes: _KeychainAttributes,
		elseSetTo new: Data
	) async throws -> (data: Data, foundExisting: Bool) {
		if let value = try await getDataWithoutAuth(
			forKey: key
		) {
			return (value, foundExisting: true)
		} else {
			try await setDataWithoutAuth(
				new,
				forKey: key,
				with: attributes
			)
			return (new, foundExisting: false)
		}
	}
}

// MARK: API - Auth
extension KeychainActor {
	
	func setDataWithAuth(
		_ data: Data,
		forKey key: Key,
		with attributes: Keychain.AttributesWithAuth
	) async throws {
		try await accessingKeychain {
//			self.assertIsolated("Should not run keychain operation on MainActor")
			dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))
			return try $0.modifier(.init(attributes: attributes))
				.set(data, key: key)
		}
			
	}
	
	/// Just an alias for
	/// `setDataWithAuth:forKey:with: KeychainAttributesWithAuth(label: label, ...)`
	func setDataWithAuth(
		_ data: Data,
		forKey key: Key,
		label: String? = nil,
		comment: String? = nil,	
		isSynchronizable: Bool = false,
		accessibility: Accessibility,
		authenticationPolicy: AuthenticationPolicy
	) async throws {
		try await setDataWithAuth(
			data,
			forKey: key,
			with: Keychain.AttributesWithAuth(
				label: label,
				comment: comment,
				isSynchronizable: isSynchronizable,
				accessibility: accessibility,
				authenticationPolicy: authenticationPolicy
			)
		)
	}
	
	func getDataWithAuth(
		forKey key: Key,
		authenticationPrompt: AuthenticationPrompt
	) async throws -> Data? {
		try await accessingKeychain {
//			self.assertIsolated("Should not run keychain operation on MainActor")
			dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))
			return try $0.modifier(.init(authPrompt: authenticationPrompt))
				.getData(key)
		}
	}
	
	@discardableResult
	func getDataWithAuthIfPresent(
		forKey key: Key,
		with attributes: Keychain.AttributesWithAuth,
		elseSetTo new: Data,
		authenticationPrompt: AuthenticationPrompt
	) async throws -> (data: Data, foundExisting: Bool) {
		if let value = try await getDataWithAuth(
			forKey: key,
			authenticationPrompt: authenticationPrompt
		) {
			return (value, foundExisting: true)
		} else {
			try await setDataWithAuth(
				new,
				forKey: key,
				with: attributes
			)
			return (new, foundExisting: false)
		}
	}
}

// MARK: API - Remove
extension KeychainActor {
	func removeData(
		forKey key: Key,
		ignoringAttributeSynchronizable: Bool = true
	) async throws {
		try await accessingKeychain {
			try $0.remove(
				key,
				ignoringAttributeSynchronizable: ignoringAttributeSynchronizable
			)
		}
	}
	
	func removeAllItems() async throws {
		try await accessingKeychain {
			try $0.removeAll()
		}
	}
}

private extension KeychainActor {
	func accessingKeychain<T>(
		_ accessingKeychain: @escaping (Keychain) throws -> T
	) async throws -> T {
//		try await withCheckedThrowingContinuation { continuation in
//			queue.async {
//				self.semaphore.wait()
//				do {
//					let res = try accessingKeychain(self.keychain)
//					continuation.resume(returning: res)
//				} catch {
//					continuation.resume(throwing: error)
//				}
//				self.semaphore.signal()
//			}
//		}
		try accessingKeychain(self.keychain)
	}
}
