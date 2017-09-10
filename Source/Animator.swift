import Foundation
import UIKit

open class Animator<PresentingViewController: UIViewController, PresentedViewController: UIViewController>: NSObject, UIViewControllerAnimatedTransitioning {
  
  public let duration: Double
  public var registeredContextualViews: (() -> ([ContextualViewPair]))?
  public var transitionContext: UIViewControllerContextTransitioning?
  
  public init(duration: Double) {
    self.duration = duration
  }
  
  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
  open func prepareAnimationBlock(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingViewController, to presentedVC: PresentedViewController) {
    // Store reference of transition context
    self.transitionContext = transitionContext
  }
  
  open func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingViewController, to presentedVC: PresentedViewController, completion: @escaping ()-> ()) {
    // Should be subclassed; here we define how the presented view controller
    // is animated in while the presenting view controller is animated out.
  }
  
  open func completeAnimation(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingViewController, to presentedVC: PresentedViewController) {
    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
  }
  
  open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    let fromVC =  transitionContext.viewController(forKey: self is CustomPresenterDelegate ? .from : .to) as! PresentingViewController
    let toVC = transitionContext.viewController(forKey: self is CustomPresenterDelegate ? .to : .from) as! PresentedViewController
    
    let isPresenting = self is CustomPresenterDelegate
    
    // Animate Contextual Views before preparation and primary animations if animator is a dismissor.
    // Animate Contextual Views at the end if animator is presenter.
    func animationContextualViewsIfNecessary() {
    
      if let contextualViews = registeredContextualViews?() {
        UIViewController.animateContextualViews(
          isPresenting: self is CustomPresenterDelegate,
          using: transitionContext,
          contextualViews: contextualViews,
          from: fromVC,
          to: toVC,
          duration: duration
        )
      }
    }
    
    if !isPresenting { animationContextualViewsIfNecessary() }
    
    prepareAnimationBlock(using: transitionContext, from: fromVC, to: toVC)
    performAnimations(using: transitionContext, from: fromVC, to: toVC) {
      self.completeAnimation(using: transitionContext, from: fromVC, to: toVC)
    }
    
    if isPresenting { animationContextualViewsIfNecessary() }
  }
 
  
}

extension UIViewController {
  
  public static func animateContextualViews(isPresenting: Bool, using transitionContext: UIViewControllerContextTransitioning? = nil, contextualViews: [ContextualViewPair], from presentingVC: UIViewController, to presentedVC: UIViewController, duration: Double) {
    
    let startingVC = isPresenting ? presentingVC: presentedVC
    let destinationVC = isPresenting ? presentedVC : presentingVC
    
    guard let container = transitionContext?.containerView ?? UIApplication.shared.keyWindow else {
      // No container to perform involved animated views over!
      return
    }
    
    let canvas = UIView(frame: container.bounds)
    container.addSubview(canvas)
    
    
    for viewConfig in contextualViews {
      
      let startingView = isPresenting ? viewConfig.fromView : viewConfig.toView
      let destinationView = isPresenting ? viewConfig.toView : viewConfig.fromView
      
      guard let snapshot = startingView.snapshotView(afterScreenUpdates: isPresenting) else {
        print("Could not generate snapshot from contextual view durating view controller transition - view might not be on screen")
        continue
      }
      
      let startingFrame = startingVC.view.convert(startingView.frame, to: canvas)
      let startingCenter = startingVC.view.convert(startingView.center, to: canvas)
      
      snapshot.frame = startingFrame
      snapshot.center = startingCenter
      
      canvas.addSubview(snapshot)
      
      startingView.alpha = 0
      destinationView.alpha = 0
      
      UIView.animateKeyframes(
        withDuration: duration,
        delay: 0,
        options: UIViewKeyframeAnimationOptions.calculationModeLinear,
        animations: {
          UIView.addKeyframe(
            withRelativeStartTime: 0,
            relativeDuration: duration) {
              
              let frame = destinationVC.view.convert(destinationView.frame, to: canvas)
              let center = destinationVC.view.convert(destinationView.center, to: canvas)
              snapshot.frame = frame
              snapshot.center = center
          }
          
      }) { _ in
        
        destinationView.alpha = 1
        canvas.removeFromSuperview()
      }
    }
  }
}
