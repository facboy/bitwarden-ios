import AuthenticatorBridgeKitMocks
import CryptoKit
import Foundation
import XCTest

@testable import AuthenticatorBridgeKit

final class SharedCryptographyServiceTests: AuthenticatorBridgeKitTestCase {
    // MARK: Properties

    let items: [AuthenticatorBridgeItemDataView] = AuthenticatorBridgeItemDataView.fixtures()
    var sharedKeychainRepository: MockSharedKeychainRepository!
    var subject: SharedCryptographyService!

    // MARK: Setup & Teardown

    override func setUp() {
        super.setUp()
        sharedKeychainRepository = MockSharedKeychainRepository()
        sharedKeychainRepository.authenticatorKey = sharedKeychainRepository.generateMockKeyData()
        subject = DefaultAuthenticatorCryptographyService(
            sharedKeychainRepository: sharedKeychainRepository
        )
    }

    override func tearDown() {
        sharedKeychainRepository = nil
        subject = nil
        super.tearDown()
    }

    // MARK: Tests

    /// Verify that `SharedCryptographyService.decryptAuthenticatorItems()' returns and empty
    /// array when the input is an empty array even when the authenticator key is missing.
    ///
    func test_decryptAuthenticatorItems_returnsEmpty() async throws {
        try sharedKeychainRepository.deleteAuthenticatorKey()
        await assertAsyncDoesNotThrow {
            let result = try await subject.decryptAuthenticatorItems([])
            XCTAssertEqual(result, [])
        }
    }

    /// Verify that `SharedCryptographyService.decryptAuthenticatorItems(:)` correctly
    /// decrypts an encrypted array of `AuthenticatorBridgeItemDataModel`.
    ///
    func test_decryptAuthenticatorItems_success() async throws {
        let encryptedItems = try await subject.encryptAuthenticatorItems(items)
        let decryptedItems = try await subject.decryptAuthenticatorItems(encryptedItems)

        XCTAssertEqual(items, decryptedItems)
    }

    /// Verify that `SharedCryptographyService.decryptAuthenticatorItems()' throws
    /// when the `SharedKeyRepository` authenticator key is missing.
    ///
    func test_decryptAuthenticatorItems_throwsKeyMissingError() async throws {
        let encryptedItems = try await subject.encryptAuthenticatorItems(items)
        let error = SharedKeychainServiceError.keyNotFound(SharedKeychainItem.authenticatorKey)

        try sharedKeychainRepository.deleteAuthenticatorKey()
        await assertAsyncThrows(error: error) {
            _ = try await subject.decryptAuthenticatorItems(encryptedItems)
        }
    }

    /// Verify that `SharedCryptographyService.encryptAuthenticatorItems(:)` correctly
    /// encrypts an array of `AuthenticatorBridgeItemDataView` into
    /// `AuthenticatorBridgeItemDataModel`.
    ///
    func test_encryptAuthenticatorItems_success() async throws {
        let encryptedItems = try await subject.encryptAuthenticatorItems(items)

        XCTAssertEqual(items.count, encryptedItems.count)

        for index in 0 ..< items.count {
            let item = try XCTUnwrap(items[index])
            let encryptedItem = try XCTUnwrap(encryptedItems[index])

            // Unencrypted values remain equal
            XCTAssertEqual(item.favorite, encryptedItem.favorite)
            XCTAssertEqual(item.id, encryptedItem.id)

            // Encrypted values should not remain equal, unless they were `nil`
            XCTAssertNotEqual(item.name, encryptedItem.name)
            if item.accountDomain != nil {
                XCTAssertNotEqual(item.accountDomain, encryptedItem.accountDomain)
            } else {
                XCTAssertNil(encryptedItem.accountDomain)
            }
            if item.accountEmail != nil {
                XCTAssertNotEqual(item.accountEmail, encryptedItem.accountEmail)
            } else {
                XCTAssertNil(encryptedItem.accountEmail)
            }
            if item.totpKey != nil {
                XCTAssertNotEqual(item.totpKey, encryptedItem.totpKey)
            } else {
                XCTAssertNil(encryptedItem.totpKey)
            }
            if item.username != nil {
                XCTAssertNotEqual(item.username, encryptedItem.username)
            } else {
                XCTAssertNil(encryptedItem.username)
            }
        }
    }

    /// Verify that `SharedCryptographyService.encryptAuthenticatorItems()' throws
    /// when the `SharedKeyRepository` authenticator key is missing.
    ///
    func test_encryptAuthenticatorItems_throwsKeyMissingError() async throws {
        let error = SharedKeychainServiceError.keyNotFound(SharedKeychainItem.authenticatorKey)

        try sharedKeychainRepository.deleteAuthenticatorKey()
        await assertAsyncThrows(error: error) {
            _ = try await subject.encryptAuthenticatorItems(items)
        }
    }
}
