import UIKit
import Moves

public class BaseViewController: UIViewController {
  
  @IBOutlet var item: UIView!

  var movesCoordinator: MovesCoordinator<SlideUpWithContextAnimator<BaseViewController, DetailViewController>, SlideDownAnimator<BaseViewController, DetailViewController>, BaseViewController, DetailViewController>?

  @IBAction func transitionButtonPressed(_ sender: Any) {
    
    movesCoordinator = MovesCoordinator(
      presenter: SlideUpWithContextAnimator<BaseViewController, DetailViewController>(
        verticalOffset: self.view.bounds.height * 2/15,
        relativeSizeToParent: 13/15,
        sideOffset: 0,
        duration: 0.6,
        dismissOnBackgroundTap: true
      ),
      
      dismisser: SlideDownAnimator<BaseViewController, DetailViewController>(duration: 0.6)
    )
    
    
    let vc = storyboard!.instantiateViewController(withIdentifier: "vc2") as! DetailViewController
    
    movesCoordinator?.present(vc, presentingVC: self, with: { [weak self] () -> ([ContextualViewPair]) in
      
      guard let strongSelf = self else { return [] }
      
      // Register contextual views
      return [ContextualViewPair(strongSelf.item, vc.detailItem)]
    })
    
//    let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//    
//    DispatchQueue.main.asyncAfter(deadline: delayTime) {
//      self.movesCoordinator?.resize(verticalOffset: self.view.bounds.height * 1/2, fromTop: true, relativeSizeToParent: 1/2, sideOffset: 20)
//    }
    
  }
}



