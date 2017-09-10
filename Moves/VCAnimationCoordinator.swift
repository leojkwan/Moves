import Foundation

import UIKit

/// This object presents popup view controllers in modal fashion
/// It implements the transitioning delegate method on behalf
/// of a presenting view controller.

/*
 * 1. Set the presenting view controller's transitioning delegate to this object
 * 2. Pass an presenting and dismissing(optional) object on initialization
 */

public protocol CustomPresenterDelegate: class {
}

public protocol CustomDismisserDelegate: class {
  
}

public typealias ContextualViewPair = (fromView: UIView, toView: UIView)

open class PresentAnimater<PresentingViewController: UIViewController, PresentedViewController: UIViewController>: Animator<PresentingViewController, PresentedViewController>, CustomPresenterDelegate {
  
}

open class DismissAnimater<PresentingViewController: UIViewController, PresentedViewController: UIViewController>: Animator<PresentingViewController, PresentedViewController>, CustomDismisserDelegate {
  
}

open class VCAnimationCoordinator<PresentingViewController: UIViewController, PresentedViewController: UIViewController>: NSObject, UIViewControllerTransitioningDelegate  {

  fileprivate var dimBackground: UIView!
  
  public let presenter: PresentAnimater<PresentingViewController, PresentedViewController>
  public let dismisser: DismissAnimater<PresentingViewController, PresentedViewController>
  public let options: MovesConfiguration
  public let unwindContextualViewsOnDismiss: Bool = true
  public var registeredContextualViews: (() -> ([ContextualViewPair]))?
  
  public struct MovesConfiguration {
    
    static func defaultConfig() -> MovesConfiguration {
      return MovesConfiguration(dismissOnTap: true)
    }
    
    let dismissOnTap: Bool
  }
  
  public init(
    presenter: PresentAnimater<PresentingViewController, PresentedViewController>,
    dismisser: DismissAnimater<PresentingViewController, PresentedViewController>,
    options: MovesConfiguration = MovesConfiguration.defaultConfig()) {
    self.presenter = presenter
    self.dismisser = dismisser
    self.options = options
  }
  
  public func present(_ destinationVC: UIViewController, presentingVC: UIViewController, with registeredContextualViews: (()->([ContextualViewPair]))? = nil){
    
    self.registeredContextualViews = registeredContextualViews
    self.presenter.registeredContextualViews = registeredContextualViews
    
    if unwindContextualViewsOnDismiss {
      self.dismisser.registeredContextualViews = registeredContextualViews
    }
    
    destinationVC.transitioningDelegate = self
    destinationVC.modalPresentationStyle = .overCurrentContext
    presentingVC.present(destinationVC, animated: true, completion: nil)
  }
  
  public func dismiss(_ destinationVC: UIViewController, presentingVC: UIViewController, with registeredContextualViews: (()->([ContextualViewPair]))? = nil){
    
    self.registeredContextualViews = registeredContextualViews
    
    if let specificContextualViews = registeredContextualViews {
      self.dismisser.registeredContextualViews = specificContextualViews
    }
    
    destinationVC.transitioningDelegate = self
    destinationVC.modalPresentationStyle = .overCurrentContext
    presentingVC.present(destinationVC, animated: true, completion: nil)
  }
  
  public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return presenter
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return dismisser
  }
  
  private func removeDim(duration: TimeInterval) {
    UIView.animate(withDuration: duration, delay: 0, options: [], animations: { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.dimBackground.backgroundColor = UIColor(white: 0.0, alpha: 0)
      }, completion: nil)
  }
  
  internal func dimBackgroundTapped() {
    // Register listener to dimView to dismiss on tap
    if options.dismissOnTap {
      removeDim(duration: 1)
    }
  }
  
  private func presentDimIfNecessary(using transitionContext: UIViewControllerContextTransitioning) {
    let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
    let containerView = transitionContext.containerView
    
    // Create dim view
    dimBackground = UIView(frame: containerView.bounds)
    dimBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    dimBackground.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    containerView.insertSubview(dimBackground, belowSubview: toView)
    
    // Add gesture recognizer to dim view
    let tap = UITapGestureRecognizer(target: self, action: #selector(dimBackgroundTapped))
    dimBackground.addGestureRecognizer(tap)
    
    UIView.animate(withDuration: 0.4, delay: 0, options: [], animations: {
      self.dimBackground.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
    }, completion: nil)
  }
}

public protocol ContextualAnimatable: class {
  var registeredContextualViews: (()->([ContextualViewPair]))! { get set }
}
