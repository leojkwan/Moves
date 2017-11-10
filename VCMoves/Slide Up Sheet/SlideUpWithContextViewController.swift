import UIKit
import Moves


public class SlideUpWithContextViewController: UIViewController {
  
  @IBOutlet var titleTextLabel: UILabel!
  @IBOutlet var item: UIView!
  
  lazy var movesCoordinator: MovesCoordinator<UINavigationController, SlideUpWithContextModalViewController> = {
    
    let modalConfig = ModalConfiguration()
    modalConfig.sideOffset = 10
    modalConfig.height = self.view.bounds.height * 13/15
    modalConfig.verticalAlignment = .bottom
    modalConfig.roundedCorners = [.topLeft, .topRight]
    modalConfig.roundedCornersRadius = 5
    
    let presenter = SlideInAnimator<UINavigationController, SlideUpWithContextModalViewController>(
      modalConfig: modalConfig,
      duration: 0.5,
      dismissOnBackgroundTap: true
    )
    
    let dismisser = SlideOutAnimator<UINavigationController, SlideUpWithContextModalViewController>(duration: 0.4)
    
    let coordinator = MovesCoordinator(
      presenter: presenter,
      dismisser: dismisser
    )
    
    coordinator.movesConfig.pannable = true
    coordinator.panConfig.dismissRadiusThreshold = 100
    
    return coordinator
  }()
  
  @IBAction func transitionButtonPressed(_ sender: Any) {
    
    let vc = storyboard!.instantiateViewController(withIdentifier: "SlideUpWithContextModalViewController") as! SlideUpWithContextModalViewController
    
    movesCoordinator.panConfig.lockedDirections = [.left, .right, .up]
    
    movesCoordinator.present(vc, presentingVC: self.navigationController!, with: { [weak self] () -> ([ContextualViewPair]) in
      
      guard let strongSelf = self else { return [] }
      
      // Register contextual views
      return [
        ContextualViewPair(strongSelf.item, vc.detailItem),
        ContextualViewPair(strongSelf.titleTextLabel, vc.detailTitleTextLabel)
      ]
    })
  }
}



