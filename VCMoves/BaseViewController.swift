import UIKit
import Moves

public class BaseViewController: UIViewController {
  
  @IBOutlet var titleTextLabel: UILabel!
  @IBOutlet var item: UIView!
  
  lazy var movesCoordinator: MovesCoordinator<SlideUpWithContextAnimator<BaseViewController, DetailViewController>, SlideDownAnimator<BaseViewController, DetailViewController>, BaseViewController, DetailViewController> = {
    let presenter = SlideUpWithContextAnimator<BaseViewController, DetailViewController>(
      verticalOffset: self.view.bounds.height * 2/15,
      presentedHeight: self.view.bounds.height * 13/15,
      sideOffset: 0,
      duration: 0.6,
      dismissOnBackgroundTap: true
    )
    
    let dismisser = SlideDownAnimator<BaseViewController, DetailViewController>(duration: 0.6)
    
    return MovesCoordinator(
      presenter: presenter,
      dismisser: dismisser
    )
  }()
  
  
  @IBAction func transitionButtonPressed(_ sender: Any) {
    
    
    
    let vc = storyboard!.instantiateViewController(withIdentifier: "vc2") as! DetailViewController
    
    movesCoordinator.present(vc, presentingVC: self, with: { [weak self] () -> ([ContextualViewPair]) in
      
      guard let strongSelf = self else { return [] }
      
      // Register contextual views
      return [
        ContextualViewPair(strongSelf.item, vc.detailItem),
        ContextualViewPair(strongSelf.titleTextLabel, vc.detailTitleTextLabel)
      ]
    })
    
    //    let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    //
    //    DispatchQueue.main.asyncAfter(deadline: delayTime) {
    //      self.movesCoordinator?.resize(verticalOffset: self.view.bounds.height * 1/2, fromTop: true, relativeSizeToParent: 1/2, sideOffset: 20)
    //    }
    
  }
}



