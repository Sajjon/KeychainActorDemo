import Foundation
import KeychainAccess

extension KeychainAccess.Accessibility: @unchecked Sendable {}
extension KeychainAccess.AuthenticationPolicy: @unchecked Sendable {}


public enum KeychainClient {
	public typealias Key = String
	public typealias Label = String
	public typealias Comment = String
	public typealias AuthenticationPrompt = String
}

extension KeychainClient {
	public struct SetItemWithAuthRequest: Sendable, Equatable, SetKeychainItemWithRequest {
		public let data: Data
		public let key: Key
		public let iCloudSyncEnabled: Bool
		public let accessibility: KeychainAccess.Accessibility
		public let authenticationPolicy: AuthenticationPolicy
		public let comment: Comment?
		public let label: Label?
		
		public init(
			data: Data,
			key: Key,
			iCloudSyncEnabled: Bool,
			accessibility: KeychainAccess.Accessibility,
			authenticationPolicy: AuthenticationPolicy,
			label: Label?,
			comment: Comment?
		) {
			self.data = data
			self.key = key
			self.iCloudSyncEnabled = iCloudSyncEnabled
			self.accessibility = accessibility
			self.authenticationPolicy = authenticationPolicy
			self.label = label
			self.comment = comment
		}
	}
	
	public struct SetItemWithoutAuthRequest: Sendable, Equatable, SetKeychainItemWithRequest {
		public let data: Data
		public let key: Key
		public let iCloudSyncEnabled: Bool
		public let accessibility: KeychainAccess.Accessibility
		public let label: Label?
		public let comment: Comment?
		
		public init(
			data: Data,
			key: Key,
			iCloudSyncEnabled: Bool,
			accessibility: KeychainAccess.Accessibility,
			label: Label?,
			comment: Comment?
		) {
			self.data = data
			self.key = key
			self.iCloudSyncEnabled = iCloudSyncEnabled
			self.accessibility = accessibility
			self.label = label
			self.comment = comment
		}
	}
}

public protocol SetKeychainItemWithRequest {
	var data: Data { get }
	var iCloudSyncEnabled: Bool { get }
	var key: KeychainClient.Key { get }
	var accessibility: KeychainAccess.Accessibility { get }
	var label: KeychainClient.Label? { get }
	var comment: KeychainClient.Comment? { get }
}
