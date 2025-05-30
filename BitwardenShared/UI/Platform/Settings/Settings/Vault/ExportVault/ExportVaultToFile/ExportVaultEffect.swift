// MARK: - VaultAutofillListEffect

/// Effects handled by the `ExportVaultProcessor`.
///
enum ExportVaultEffect: Equatable {
    /// The export vault button was tapped.
    case exportVaultTapped

    /// Any initial data for the view should be loaded.
    case loadData

    /// The send verification code button was tapped.
    case sendCodeTapped
}
