import Foundation
import Foundation
import UIKit

open class SlideUpWithContextAnimator: Animator<UIViewController, UIViewController> {
  
  fileprivate lazy var pan: UIPanGestureRecognizer = {
    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    return pan
  }()
  
  fileprivate var presentingVCScale: CGFloat = 1
  fileprivate var verticalOffset: CGFloat
  fileprivate var sideOffset: CGFloat
  fileprivate var dismissOnBackgroundTap: Bool
  fileprivate var fromTop: Bool = true
  fileprivate var dimAlpha: CGFloat = 0.5
  fileprivate var relativeSizeToParent: CGFloat
  fileprivate var animationOptions: UIViewAnimationOptions = .curveLinear
  fileprivate var originPoint: CGPoint!
  private var transitionContext: UIViewControllerContextTransitioning?
  
  public required init(
    verticalOffset: CGFloat,
    fromTop: Bool = true,
    relativeSizeToParent: CGFloat = 1,
    sideOffset: CGFloat = 20,
    duration: Double = 0.6,
    dismissOnBackgroundTap shouldDismiss: Bool = false,
    animationOptions: UIViewAnimationOptions = .curveLinear
    ) {
    self.fromTop = fromTop
    self.verticalOffset = verticalOffset
    self.sideOffset = sideOffset
    self.relativeSizeToParent = relativeSizeToParent
    self.dismissOnBackgroundTap = shouldDismiss
    self.animationOptions = animationOptions
    super.init(duration: duration)
  }
  
  func disablePan(disable: Bool) {
    pan.isEnabled = !disable
  }
  
  override open func prepareAnimationBlock(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: UIViewController, to presentedVC: UIViewController) {
    
    super.prepareAnimationBlock(using: transitionContext, from: presentingVC, to: presentedVC)
    
    self.transitionContext = transitionContext
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    containerView.addSubview(toView)
    toView.layer.cornerRadius = 5
    toView.clipsToBounds = true
    
    // Update toView size
    let toViewHeight = containerView.bounds.height * relativeSizeToParent
    
    toView.bounds.size = CGSize(
      width: containerView.bounds.width - sideOffset,
      height: toViewHeight
    )
    
    // Push beneath visible view
    toView.center = CGPoint(
      x: containerView.frame.midX,
      y: containerView.frame.midY + containerView.frame.height
    )
  }
  override open func completeAnimation(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: UIViewController, to presentedVC: UIViewController) {
    super.completeAnimation(using: transitionContext, from: presentingVC, to: presentedVC)
    
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    toView.addGestureRecognizer(self.pan)
    
    // keep a reference of origin when we need to
    // animated back to starting position(minimal pan gestures)
    self.originPoint = toView.frame.origin
  }

  
  open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: UIViewController, to presentedVC: UIViewController, completion: @escaping () -> ()) {
    
    UIView.animateKeyframes(
      withDuration: duration,
      delay: 0,
      options: UIViewKeyframeAnimationOptions.calculationModeLinear,
      animations: {
        
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: self.duration) {
            
            presentingVC.view.transform = CGAffineTransform(scaleX: self.presentingVCScale, y: self.presentingVCScale)
            presentingVC.view.layer.cornerRadius = 4
            presentingVC.view.layer.masksToBounds = true
        }
        
        UIView.addKeyframe(
          withRelativeStartTime: 0,
          relativeDuration: self.duration) {
            
            // Offset from top or bottom
            presentedVC.view.frame.origin.y = self.fromTop ?
              self.verticalOffset:
              (transitionContext.containerView.bounds.maxY - presentedVC.view.bounds.height) - self.verticalOffset
        }
        
    }) { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
    }
  }
  
  func resize(
    verticalOffset: CGFloat,
    fromTop: Bool = true,
    relativeSizeToParent: CGFloat = 1,
    sideOffset: CGFloat = 20
    ){
    
    guard let transitionContext = self.transitionContext else { return }
    
    let fromVC = transitionContext.viewController(forKey: .from)!
    let toVC = transitionContext.viewController(forKey: .to)!
    
    toVC.beginAppearanceTransition(true, animated: true)
    
    let repositionedX = sideOffset/2
    let repositionedY = fromTop ?
      verticalOffset:
      fromVC.view.bounds.height - verticalOffset
    
    UIView.animate(withDuration: 0.3) {
      toVC.view.frame = CGRect(
        x: repositionedX,
        y: repositionedY,
        width: fromVC.view.bounds.width - sideOffset,
        height: fromVC.view.bounds.height * relativeSizeToParent
      )
    }
    
    // Update origin point
    self.originPoint = toVC.view.frame.origin
    
    toVC.view.translatesAutoresizingMaskIntoConstraints = true
    toVC.view.layoutIfNeeded()
    toVC.endAppearanceTransition()
  }
  
  func handlePan(_ gesture: UIPanGestureRecognizer) {
    
    guard let presentedVC = self.transitionContext?.viewController(forKey: .from)! else { return }
    
    
    guard let toView = gesture.view else { return }
    // On Pan
    let translation = gesture.translation(in: toView)
    
    toView.center = CGPoint(
      x: toView.center.x,
      y: toView.center.y + translation.y
    )
    
    gesture.setTranslation(CGPoint.zero, in: toView)
    
    // On Release
    if(gesture.state == .ended) {
      
      let yDistanceFromCenter = originPoint.y - toView.frame.origin.y
      
      DispatchQueue.main.async {
        if (yDistanceFromCenter < -150) {
          
          presentedVC.dismiss(animated: true, completion: nil)
          
        } else {
          
          UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1,
            options: [],
            animations: {
              toView.frame.origin = self.originPoint
          }, completion: nil)
        }
      }
    }
  }
}
