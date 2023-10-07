import Foundation
import KeychainAccess

extension Keychain {
	func withAttributes(
		accessibility: Accessibility,
		isSynchronizable: Bool,
		authenticationPolicy: AuthenticationPolicy?,
		label: String?,
		comment: String?
	) -> Keychain {
		var modified = synchronizable(isSynchronizable)
		if let label {
			modified = modified.label(label)
		}
		if let comment {
			modified = modified.comment(comment)
		}
		if let authenticationPolicy {
			modified = modified.accessibility(accessibility, authenticationPolicy: authenticationPolicy)
		} else {
			modified = modified.accessibility(accessibility)
		}
		return modified
	}
}

final actor KeychainActor: GlobalActor {
	static let shared = KeychainActor()
	private let keychain: Keychain
	private init() {
		self.keychain = Keychain(service: "MyService")
	}
}

extension KeychainActor {
	
	private func sync<T>(
		_ work: @escaping () throws -> T
	) async throws -> T {
		//		try await Task {
		try work()
		//		}.value
	}
}

// MARK: API - No Auth
extension KeychainActor {
	func setDataWithoutAuth(
		data: Data,
		forKey key: Key,
		accessibility: Accessibility,
		isSynchronizable: Bool = false,
		label: String? = nil,
		comment: String? = nil
	) async throws {
		try await sync {
			try self.keychain
				.withAttributes(
					accessibility: accessibility,
					isSynchronizable: isSynchronizable,
					authenticationPolicy: nil,
					label: label,
					comment: comment
				)
				.set(data, key: key)
		}
	}
	
	func getDataWithoutAuth(
		forKey key: Key
	) async throws -> Data? {
		try await sync {
			try self.keychain.getData(key)
		}
	}
	
}

// MARK: API - Auth
extension KeychainActor {
	func setDataWithAuthForKey(
		data: Data,
		forKey key: Key,
		accessibility: Accessibility,
		authenticationPolicy: AuthenticationPolicy,
		isSynchronizable: Bool = false,
		label: String? = nil,
		comment: String? = nil
	) async throws {
		try await sync {
			try self.keychain
				.withAttributes(
					accessibility: accessibility,
					isSynchronizable: isSynchronizable,
					authenticationPolicy: authenticationPolicy,
					label: label,
					comment: comment
				)
				.set(data, key: key)
		}
	}
	
	func getDataWithAuthForKey(
		forKey key: Key,
		authPrompt: AuthenticationPrompt
	) async throws -> Data? {
		try await sync {
			try self.keychain
				.authenticationPrompt(authPrompt)
				.getData(key)
		}
	}
	
}

// MARK: API - Remove
extension KeychainActor {
	func removeData(
		forKey key: Key
	) async throws {
		try await sync {
			try self.keychain.remove(key)
		}
	}
	
	func removeAllItems() async throws {
		try await sync {
			try self.keychain.removeAll()
		}
	}
}

