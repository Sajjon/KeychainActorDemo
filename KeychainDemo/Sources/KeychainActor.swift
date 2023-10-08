import Foundation
import KeychainAccess

public final actor KeychainActor: GlobalActor {
	
	private let keychain: ManagedCriticalState<Keychain>
	
	private init() {
		self.keychain = .init(Keychain(service: "MyService"))
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
	) throws {
		try accessingKeychain {
			try $0.modifier(.init(attributes: attributes))
				.set(data, key: key)
		}
	}
	
	func setDataWithoutAuth(
		data: Data,
		forKey key: Key,
		label: String? = nil,
		comment: String? = nil,
		isSynchronizable: Bool = false,
		accessibility: Accessibility
	) throws {
		try setDataWithoutAuth(
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
	) throws -> Data? {
		try accessingKeychain {
			try $0.getData(key)
		}
	}
	
}

// MARK: API - Auth
extension KeychainActor {
	
	func authenticatedSetData(
		_ data: Data,
		forKey key: Key,
		with attributes: Keychain.AttributesWithAuth
	) throws {
		try accessingKeychain {
			try $0.modifier(.init(attributes: attributes))
				.set(data, key: key)
		}
			
	}
	
	/// Just an alias for `authenticatedSetData:forKey:with`
	func setDataWithAuth(
		data: Data,
		forKey key: Key,
		with attributes: Keychain.AttributesWithAuth
	) throws {
		try authenticatedSetData(data, forKey: key, with: attributes)
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
	) throws {
		try setDataWithAuth(
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
	) throws {
		try setDataWithAuth(
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
	) throws -> Data? {
		try accessingKeychain {
			try $0.modifier(.init(authPrompt: authenticationPrompt))
				.getData(key)
		}
	}
	
}

// MARK: API - Remove
extension KeychainActor {
	func removeData(
		forKey key: Key,
		ignoringAttributeSynchronizable: Bool = true
	) throws {
		try accessingKeychain {
			try $0.remove(
				key,
				ignoringAttributeSynchronizable: ignoringAttributeSynchronizable
			)
		}
	}
	
	func removeAllItems() async throws {
		try accessingKeychain {
			try $0.removeAll()
		}
	}
}

private extension KeychainActor {
	func accessingKeychain<T>(
		_ accessingKeychain: (inout Keychain) throws -> T
	) throws -> T {
		try self.keychain.withCriticalRegion(accessingKeychain)
	}
}
