import Foundation
import Foundation
import UIKit


open class FadeInOverContextAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: Animator<PresentingVC, PresentedVC>, ModalAnimator {
  
  fileprivate var presentingVCScale: CGFloat = 1
  public var modalConfig: ModalConfiguration
  
  public required init(
    modalConfig: ModalConfiguration = ModalConfiguration(),
    duration: Double = 0.6
    ) {
    
    self.modalConfig = modalConfig
    super.init(isPresenter: true, duration: duration)
  }
  
  func calculateToVCSizeAndFrame() {
    
  }
  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let destininationModalOriginPoint = self.determineModalOriginPoint(from: containerView)
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    containerView.addSubview(toView)
    
    // Define frame
    toView.frame = CGRect(
      x: destininationModalOriginPoint.x,
      y: destininationModalOriginPoint.y,
      width: modalConfig.width,
      height: modalConfig.height
    )
    
    toView.alpha = 0
    
    // Add Corner Radius to presenting view
    let maskLayer = CAShapeLayer()
    maskLayer.path = UIBezierPath(
      roundedRect:toView.bounds,
      byRoundingCorners: modalConfig.roundedCorners,
      cornerRadii: CGSize(width: modalConfig.roundedCornersRadius, height:  modalConfig.roundedCornersRadius)
      ).cgPath
    toView.layer.mask = maskLayer
    
    UIView.animate(withDuration: duration, animations: {
      toView.alpha = 1
    }) { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
    }
  }
}

