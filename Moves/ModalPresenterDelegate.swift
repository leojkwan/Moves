import Foundation
import UIKit

/// Delegate presented modal events
public protocol ModalDismisserDelegate: class {
  func didDismissModal()
  func willDismissModal()
}
