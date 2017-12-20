import Foundation
import UIKit

class MasterViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  // MARK: UIViewControllerTransitioningDelegate
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
  
  // MARK: UIViewControllerAnimatedTransitioning
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 1
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    // ** Add your custom animation logic here **
    
    guard let fromVC = transitionContext.viewController(forKey: .from),
      let toVC = transitionContext.viewController(forKey: .to) else { return }
    
    // Start with destination vc hidden
    toVC.view.alpha = 0
    
    // Add toVC to container view of animation
    transitionContext.containerView.addSubview(toVC.view)
    toVC.view.frame = transitionContext.containerView.frame
    
    let totalDuration = self.transitionDuration(using: transitionContext)
    
    UIView.animate(withDuration: totalDuration, animations: {
      fromVC.view.alpha = 0
      toVC.view.alpha = 1
    }) { _ in
      transitionContext.completeTransition(true)
    }
  }
  
  @IBAction func transitionButtonPressed(_ sender: Any) {
    
    let dvc = storyboard!.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
      
    // We are managing the destination view controller's animation on its behalf.
    // As a result, the system will call the 'transitionDuration:' and
    // 'animateTransition:transitionContext:' methods we declared above
    // when coordinating this custom transition.
    dvc.transitioningDelegate = self
    
    present(dvc, animated: true, completion: nil)
  }
}


class ModalViewController: UIViewController {
  
  @IBAction func dismiss(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
}
