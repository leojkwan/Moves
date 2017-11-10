import Foundation
import Foundation
import UIKit

open class SlideInOverContextAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: Animator<PresentingVC, PresentedVC>, TransformAnimator, ModalAnimator {
  
  fileprivate var presentingVCScale: CGFloat = 1
  fileprivate var slidingFrom: Direction
  
  fileprivate var animationOptions: UIViewAnimationOptions = .curveLinear
  public var modalConfig: ModalConfiguration
  
  public required init(
    slidingFrom: Direction,
    modalConfig: ModalConfiguration = ModalConfiguration(),
    duration: Double = 0.6,
    animationOptions: UIViewAnimationOptions = .curveLinear
    ) {
    self.slidingFrom = slidingFrom
    self.modalConfig = modalConfig
    self.animationOptions = animationOptions
    super.init(isPresenter: true, duration: duration)
  }
  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    containerView.addSubview(toView)
    
    // Define frame
    toView.frame.size = CGSize(
      width: modalConfig.width,
      height: modalConfig.height
    )
    
    let destininationModalOriginPoint = self.determineModalOriginPoint(from: containerView)
    toView.frame.origin = destininationModalOriginPoint
    
    // Set initial frame by determining where modal is sliding from and
    // setting appropriate center point such that modal begins out of view.
    // Set non-translated origin point here so that slide animates on 1 axis
    // only. This prevents any diagonal slides (subclass Animator on your own if you
    // want that capability!)
    switch slidingFrom {
    case .up:
      toView.frame.origin.y -= containerView.frame.height
    case .down:
      toView.frame.origin.y += containerView.frame.height
    case .left:
      toView.frame.origin.x -= containerView.frame.width
    case .right:
      toView.frame.origin.x += containerView.frame.width
    }
    
    
    // Add Corner Radius to presenting view
    let maskLayer = CAShapeLayer()
    maskLayer.path = UIBezierPath(
      roundedRect:toView.bounds,
      byRoundingCorners: modalConfig.roundedCorners,
      cornerRadii: CGSize(width: modalConfig.roundedCornersRadius, height:  modalConfig.roundedCornersRadius)
      ).cgPath
    toView.layer.mask = maskLayer
    
    // Animate
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0,
      options: [],
      animations: { [weak self] in
        
        guard let strongSelf = self else { return }
        
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: strongSelf.duration) {
            
            /*
             * Animate 'from' view controller.
             */
            
            // Scale
            presentingVC.view.transform = CGAffineTransform(
              scaleX: strongSelf.presentingVCScale,
              y: strongSelf.presentingVCScale
            )
            
            presentedVC.view.frame.origin = destininationModalOriginPoint
        }
        
    }) { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
    }
  }
}
