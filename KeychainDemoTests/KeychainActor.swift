import Foundation
import KeychainAccess

final actor KeychainActor: GlobalActor {
	static let shared = KeychainActor()
	private let keychain: Keychain
	private let dispatchQueue = DispatchQueue(label: "keychain.background.queue")
	private init() {
		self.keychain = Keychain(service: "MyService")
	}
}

extension KeychainActor {
	private func withAttributes(
		of request: SetKeychainItemWithRequest
	) -> Keychain {
		var handle = keychain.synchronizable(request.iCloudSyncEnabled)
		if let label = request.label {
			handle = handle.label(label)
		}
		if let comment = request.comment {
			handle = handle.comment(comment)
		}
		return handle
	}
	
	private func background<T>(_ work: () throws -> T) rethrows -> T {
		try dispatchQueue.sync {
			try work()
		}
	}
}

// MARK: API - No Auth
extension KeychainActor {
	func setDataWithoutAuth(
		_ request: SetItemWithoutAuthRequest
	) throws {
		try background {
			try withAttributes(of: request)
				.accessibility(request.accessibility)
				.set(request.data, key: request.key)
		}
	}
	
	func getDataWithAuthForKey(
		forKey key: Key,
		authPrompt: AuthenticationPrompt
	) throws -> Data? {
		try background {
			try keychain
				.authenticationPrompt(authPrompt)
				.getData(key)
		}
	}
}

// MARK: API - Auth
extension KeychainActor {
	func setDataWithAuthForKey(
		_ request: SetItemWithAuthRequest
	) throws {
		try background {
			try withAttributes(of: request)
				.accessibility(request.accessibility, authenticationPolicy: request.authenticationPolicy)
				.set(request.data, key: request.key)
		}
	}
	
	func getDataWithoutAuth(
		forKey key: Key
	) throws -> Data? {
		try background {
			try keychain.getData(key)
		}
	}

}

// MARK: API - Remove
extension KeychainActor {
	func removeData(
		forKey key: Key
	) throws {
		try background {
			try keychain.remove(key)
		}
	}
	
	func removeAllItems() throws {
		try background {
			try keychain.removeAll()
		}
	}
}

