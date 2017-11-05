import Foundation
import Foundation
import UIKit


open class SlideUpWithContextAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: Animator<PresentingVC, PresentedVC> {
  
  fileprivate var presentingVCScale: CGFloat = 1
  fileprivate var verticalOffset: CGFloat
  fileprivate var sideOffset: CGFloat
  fileprivate var dismissOnBackgroundTap: Bool
  fileprivate var fromTop: Bool = true
  fileprivate var dimAlpha: CGFloat = 0.5
  fileprivate var presentedHeight: CGFloat
  fileprivate var animationOptions: UIViewAnimationOptions = .curveLinear
  
  public required init(
    verticalOffset: CGFloat,
    fromTop: Bool = true,
    presentedHeight: CGFloat,
    sideOffset: CGFloat = 20,
    duration: Double = 0.6,
    dismissOnBackgroundTap shouldDismiss: Bool = false,
    animationOptions: UIViewAnimationOptions = .curveLinear
    ) {
    self.fromTop = fromTop
    self.verticalOffset = verticalOffset
    self.sideOffset = sideOffset
    self.presentedHeight = presentedHeight
    self.dismissOnBackgroundTap = shouldDismiss
    self.animationOptions = animationOptions
    super.init(isPresenter: true, duration: duration)
  }
  
  override open func prepareAnimationBlock(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC) {
    
    super.prepareAnimationBlock(using: transitionContext, from: presentingVC, to: presentedVC)
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    containerView.addSubview(toView)
    
    toView.bounds.size = CGSize(
      width: containerView.bounds.width - sideOffset,
      height: presentedHeight
    )
    
    // Add Corner Radius to presenting view
    // Round top corners
    let maskLayer = CAShapeLayer()
    
    maskLayer.path = UIBezierPath(
      roundedRect:toView.bounds,
      byRoundingCorners:[.topRight, .topLeft],
      cornerRadii: CGSize(width: 15, height:  15)
      ).cgPath
    
    toView.layer.mask = maskLayer
    
    
    // Push beneath visible view
    toView.center = CGPoint(
      x: containerView.frame.midX,
      y: containerView.frame.midY + containerView.frame.height
    )
  }
  
  override open func completeAnimation(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC) {
    super.completeAnimation(using: transitionContext, from: presentingVC, to: presentedVC)
  }
  
  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0,
      options: UIViewKeyframeAnimationOptions.calculationModeLinear,
      animations: { [weak self] in
        
        guard let strongSelf = self else { return }
        
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: strongSelf.duration) {
            
            presentingVC.view.transform = CGAffineTransform(scaleX: strongSelf.presentingVCScale, y: strongSelf.presentingVCScale)
            presentingVC.view.layer.cornerRadius = 4
            presentingVC.view.layer.masksToBounds = true
        }
        
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: strongSelf.duration) {
            
            // Offset from top or bottom
            presentedVC.view.frame.origin.y = strongSelf.fromTop ?
              strongSelf.verticalOffset:
              (transitionContext.containerView.bounds.maxY - presentedVC.view.bounds.height) - strongSelf.verticalOffset
        }
        
    }) { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
    }
  }
  
}
