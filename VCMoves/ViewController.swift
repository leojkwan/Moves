import UIKit
import Moves

class ViewController: UIViewController {
  
  @IBOutlet var item: UIView!
  lazy fileprivate var vcAnimationCoordinator: VCAnimationCoordinator<SlideUpWithContextAnimator, SlideDownAnimator> = {
    
    let slideUp = SlideUpWithContextAnimator(
      verticalOffset: self.view.bounds.height * 1/10,
      relativeSizeToParent: 9/10,
      sideOffset: 0,
      duration: 0.6,
      dismissOnBackgroundTap: true
    )
    
    let slideDown = SlideDownAnimator(duration: 0.6)
    
    let transitioner = VCAnimationCoordinator(
      presenter: slideUp,
      dismisser: slideDown
    )
    
    return transitioner
  }()
  
  @IBAction func transitionButtonPressed(_ sender: Any) {
    let vc = storyboard!.instantiateViewController(withIdentifier: "vc2") as! DetailViewController
    vc.transitioningDelegate = vcAnimationCoordinator
    
    vcAnimationCoordinator.present(vc, presentingVC: self, with: { [weak self] () -> ([ContextualViewPair]) in
      
      guard let strongSelf = self else { return [] }
      
      // Register contextual views
      return [ContextualViewPair(strongSelf.item, vc.detailItem)]
    })
  }
  
}


