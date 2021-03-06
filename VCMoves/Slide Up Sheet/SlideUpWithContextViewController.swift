import UIKit
import Moves


public class SlideUpWithContextViewController: UIViewController {
  
  @IBOutlet var titleTextLabel: UILabel!
  @IBOutlet var item: UIView!
  public var example: MovesExample = MovesExample.fadeIn
  
  lazy var movesCoordinator: MovesCoordinator<UINavigationController, SlideUpWithContextModalViewController> = {
    
    let presenter: Animator<UINavigationController, SlideUpWithContextModalViewController>
    let dismisser: Animator<UINavigationController, SlideUpWithContextModalViewController>
    
    switch self.example {
    case MovesExample.fadeIn:
      
      let modalConfig = ModalConfiguration()
      modalConfig.width = self.view.bounds.width * 13/15
      modalConfig.height = self.view.bounds.width * 13/15
      modalConfig.roundedCorners = [.topLeft, .topRight, .bottomRight, .bottomLeft]
      modalConfig.roundedCornersRadius = 5
      
      presenter = FadeInOverContextAnimator<UINavigationController, SlideUpWithContextModalViewController>(
        modalConfig: modalConfig,
        duration: 0.6
      )
    case .slideUpWithContext:
      
      let modalConfig = ModalConfiguration()
      modalConfig.width = self.view.bounds.width * 13/15
      modalConfig.height = self.view.bounds.height * 13/15
      modalConfig.verticalAlignment = .bottom
      modalConfig.horizontalAlignment = .centered
      modalConfig.roundedCorners = [.topLeft, .topRight]
      modalConfig.roundedCornersRadius = 5
      
      presenter = SlideInOverContextAnimator<UINavigationController, SlideUpWithContextModalViewController>(
        slidingFrom: Direction.down,
        modalConfig: modalConfig,
        duration: 0.5
      )
    }
    
    switch self.example {
    case MovesExample.fadeIn:
      dismisser = FadeOutOverContextAnimator<UINavigationController, SlideUpWithContextModalViewController>(duration: 0.6)
    case .slideUpWithContext:
      dismisser = SlideOutOverContextAnimator<UINavigationController, SlideUpWithContextModalViewController>(slidingTo: .down, duration: 0.4)
    }
    
    let coordinator = MovesCoordinator(
      presenter: presenter,
      dismisser: dismisser
    )
    
    if self.example == .slideUpWithContext {
      coordinator.panConfig.lockedDirections = [.left, .right, .up]
    }
    
    coordinator.movesConfig.pannable = true
    coordinator.panConfig.dismissRadiusThreshold = 100
    
    return coordinator
  }()
  
  @IBAction func transitionButtonPressed(_ sender: Any) {
    
    let vc = storyboard!.instantiateViewController(withIdentifier: "SlideUpWithContextModalViewController") as! SlideUpWithContextModalViewController
    movesCoordinator.present(vc, presentingVC: self.navigationController!)
  }
}



