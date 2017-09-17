import Foundation

/*
 * This animated transitioning object slides modal DOWN under a screen's view.
 */
public class SlideDownAnimator<PresentingVC: UIViewController, PresentedVC: UIViewController>: DismissAnimater<PresentingVC, PresentedVC> {
  
  public var dimView: UIView?
  public var contextualViews: [ContextualViewPair] = []
  
  public override func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
  
   open override func performAnimations(using transitionContext: UIViewControllerContextTransitioning, from presentingVC: PresentingVC, to presentedVC: PresentedVC, completion: @escaping () -> ()) {
    super.performAnimations(using: transitionContext, from: presentingVC, to: presentedVC, completion: completion)
    
    // Setup the transition
    let containerView = transitionContext.containerView
    let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
    let presentingViewController = transitionContext.viewController(forKey: .to)!
    
    UIView.animateKeyframes(
      withDuration: self.duration,
      delay: 0.0,
      options: UIViewKeyframeAnimationOptions(),
      animations: {
        
        // ToView Scale back to 1
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: self.duration) {
          presentingViewController.view.alpha = 1
          presentingViewController.view.transform = .identity
          presentingViewController.view.layer.cornerRadius = 0
        }
        
        // Slide View Down
        UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: self.duration) {
          fromView.center.y += containerView.frame.maxY
        }
        
        // Fade out
        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: self.duration - 0.1) {
          fromView.alpha = 0
        }
        
    } , completion: { _ in
      
      // must call this to proceed to completing
      // view controller transition.
      completion()
    })
    
  }
  
}
