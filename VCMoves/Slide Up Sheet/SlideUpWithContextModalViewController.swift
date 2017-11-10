import Foundation
import UIKit
import Moves

public class SlideUpWithContextModalViewController: UIViewController {
  
  @IBOutlet public var detailTitleTextLabel: UILabel!
  @IBOutlet public var detailItem: UIView!
  
  @IBAction func dismiss(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
