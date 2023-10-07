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
