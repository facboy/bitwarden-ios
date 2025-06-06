import BitwardenKit
import SwiftUI

// MARK: - CompleteRegistrationState

/// An object that defines the current state of a `CompleteRegistrationView`.
///
struct CompleteRegistrationState: Equatable, Sendable {
    // MARK: Properties

    /// Whether passwords are visible in the view's text fields.
    var arePasswordsVisible: Bool = false

    /// Whether the continue button is enabled.
    var continueButtonEnabled: Bool {
        !passwordText.isEmpty
            && !retypePasswordText.isEmpty
            && passwordText.count >= requiredPasswordCount
    }

    /// Whether the user's account has been created when completing registration.
    var didCreateAccount = false

    /// Token needed to complete registration
    var emailVerificationToken: String

    /// Whether the user came from email AppLink
    var fromEmail: Bool = false

    /// Whether the check for data breaches toggle is on.
    var isCheckDataBreachesToggleOn: Bool = true

    /// Whether the password is considered weak.
    var isWeakPassword: Bool {
        guard let passwordStrengthScore else { return false }
        return passwordStrengthScore < 3
    }

    /// The text in the password hint text field.
    var passwordHintText: String = ""

    /// The text in the master password text field.
    var passwordText: String = ""

    /// A scoring metric that represents the strength of the entered password. The score ranges from
    /// 0-4 (weak to strong password).
    var passwordStrengthScore: UInt8?

    /// The required text count for the password strength.
    var requiredPasswordCount = Constants.minimumPasswordCharacters

    /// The text in the re-type password text field.
    var retypePasswordText: String = ""

    /// The email of the user that is creating the account.
    var userEmail: String

    /// A toast message to show in the view.
    var toast: Toast?
}
