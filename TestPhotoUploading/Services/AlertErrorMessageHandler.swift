import Foundation

class AlertErrorMessageHandler: ErrorHandler {
    func handle(_ errorMessage: String) {
        AlertDialogHelper.displayAlert(title: Strings.error, message: errorMessage)
    }
}
