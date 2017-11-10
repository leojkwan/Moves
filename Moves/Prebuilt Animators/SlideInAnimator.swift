import Foundation
import Foundation
import UIKit


open class SlideInAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: Animator<PresentingVC, PresentedVC>, TransformAnimator {
  
  fileprivate var presentingVCScale: CGFloat = 1
  fileprivate var dismissOnBackgroundTap: Bool
  fileprivate var dimAlpha: CGFloat = 0.5
  
  fileprivate var animationOptions: UIViewAnimationOptions = .curveLinear
  var modalConfig: ModalConfiguration
  
  public required init(
    modalConfig: ModalConfiguration = ModalConfiguration(),
    duration: Double = 0.6,
    dismissOnBackgroundTap shouldDismiss: Bool = false,
    animationOptions: UIViewAnimationOptions = .curveLinear
    ) {
    self.modalConfig = modalConfig
    self.dismissOnBackgroundTap = shouldDismiss
    self.animationOptions = animationOptions
    super.init(isPresenter: true, duration: duration)
  }
  
  func calculateToVCSizeAndFrame() {
    
  }
  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    containerView.addSubview(toView)
    
    toView.bounds.size = CGSize(
      width: containerView.bounds.width - modalConfig.sideOffset,
      height: modalConfig.height
    )
    
    // Add Corner Radius to presenting view
    let maskLayer = CAShapeLayer()
    maskLayer.path = UIBezierPath(
      roundedRect:toView.bounds,
      byRoundingCorners: modalConfig.roundedCorners,
      cornerRadii: CGSize(width: modalConfig.roundedCornersRadius, height:  modalConfig.roundedCornersRadius)
      ).cgPath
    toView.layer.mask = maskLayer
    
    // Push beneath visible view
    toView.center = CGPoint(
      x: containerView.frame.midX,
      y: containerView.frame.midY + containerView.frame.height
    )
    
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
            
            // Offset from top or bottom
            switch strongSelf.modalConfig.verticalAlignment {
            case .centered:
            presentedVC.view.center.y  = containerView.frame.midY
            case .top:
              presentedVC.view.frame.origin.y = strongSelf.modalConfig.verticalOffset
            case .bottom:
              presentedVC.view.frame.origin.y = (transitionContext.containerView.bounds.maxY - presentedVC.view.bounds.height) - strongSelf.modalConfig.verticalOffset
            }            
        }
        
    }) { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
    }
  }
}
