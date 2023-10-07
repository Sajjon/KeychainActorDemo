import Foundation
import KeychainAccess

public final actor KeychainActor: GlobalActor {
	
	private let keychain: Keychain
	
	private let backgroundQueue = DispatchQueue(
		label: "KeychainActor",
		qos: .background,
		attributes: .init(),
		autoreleaseFrequency: .never,
		target: nil
	)
	
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
		data: Data,
		forKey key: Key,
		with attributes: _KeychainAttributes
	) async throws {
		try await _setData(data, forKey: key, with: attributes)
	}
	
	func setDataWithoutAuth(
		data: Data,
		forKey key: Key,
		label: String? = nil,
		comment: String? = nil,
		isSynchronizable: Bool = false,
		accessibility: Accessibility
	) async throws {
		try await setDataWithoutAuth(
			data: data,
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
		try await _getData(forKey: key, authenticationPrompt: nil)
	}
	
}

// MARK: API - Auth
extension KeychainActor {
	
	func authenticatedSetData(
		_ data: Data,
		forKey key: Key,
		with attributes: Keychain.AttributesWithAuth
	) async throws {
		try await _setData(data, forKey: key, with: attributes)
	}
	
	/// Just an alias for `authenticatedSetData:forKey:with`
	func setDataWithAuth(
		data: Data,
		forKey key: Key,
		with attributes: Keychain.AttributesWithAuth
	) async throws {
		try await authenticatedSetData(data, forKey: key, with: attributes)
	}
	
	/// Just an alias for
	/// `authenticatedSetData:forKey:with: KeychainAttributesWithAuth(label: label, ...)`
	func authenticatedSetData(
		_ data: Data,
		forKey key: Key,
		label: String? = nil,
		comment: String? = nil,
		isSynchronizable: Bool = false,
		accessibility: Accessibility,
		authenticationPolicy: AuthenticationPolicy
	) async throws {
		try await setDataWithAuth(
			data: data,
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
	
	/// Just an alias for
	/// `authenticatedSetData:forKey:with: KeychainAttributesWithAuth(label: label, ...)`
	func setDataWithAuth(
		data: Data,
		forKey key: Key,
		label: String? = nil,
		comment: String? = nil,
		isSynchronizable: Bool = false,
		accessibility: Accessibility,
		authenticationPolicy: AuthenticationPolicy
	) async throws {
		try await setDataWithAuth(
			data: data,
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
		try await _getData(forKey: key, authenticationPrompt: authenticationPrompt)
	}
	
}

// MARK: API - Remove
extension KeychainActor {
	func removeData(
		forKey key: Key,
		ignoringAttributeSynchronizable: Bool = true
	) async throws {
		try await withCheckedThrowingContinuation { continuation in
			__onBackgroundQueue {
				continuation.resume(
					returning: try $0
						.remove(
							key,
							ignoringAttributeSynchronizable: ignoringAttributeSynchronizable
						)
				)
			} onError: {
				continuation.resume(throwing: $0)
			}
		}
	}
	
	func removeAllItems() async throws {
		try await withCheckedThrowingContinuation { continuation in
			__onBackgroundQueue {
				continuation.resume(
					returning: try $0.removeAll()
				)
			} onError: {
				continuation.resume(throwing: $0)
			}
		}
	}
}

// MARK: Private
extension KeychainActor {
	
	private func __onBackgroundQueue(
		modifier: Keychain.Modifier? = nil,
		_ work: @escaping @Sendable (Keychain) throws -> Void,
		onError: @escaping @Sendable (Error) -> Void
	) -> Void {
		backgroundQueue.asyncAndWait {
			do {
				try work(
					self.keychain.modifier(modifier)
				)
			} catch {
				onError(error)
			}
		}
	}
	
	private func _setData(
		_ data: Data,
		forKey key: Key,
		with attributes: _KeychainAttributes
	) async throws -> Void {
		try await withCheckedThrowingContinuation { continuation in
			__onBackgroundQueue(modifier: .init(attributes: attributes)) {
				try $0.set(data, key: key)
				continuation.resume()
			} onError: {
				continuation.resume(throwing: $0)
			}
		}
	}
	
	private func _getData(
		forKey key: Key,
		authenticationPrompt: AuthenticationPrompt?
	) async throws -> Data? {
		try await withCheckedThrowingContinuation { continuation in
			__onBackgroundQueue(modifier: .init(authPrompt: authenticationPrompt)) {
				continuation.resume(returning: try $0.getData(key))
			} onError: {
				continuation.resume(throwing: $0)
			}
		}
	}
}
