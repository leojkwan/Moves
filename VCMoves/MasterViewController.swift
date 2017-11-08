//
//  MasterViewController.swift
//  VCMoves
//
//  Created by Leo Kwan on 11/6/17.
//  Copyright © 2017 Leo Kwan. All rights reserved.
//

import Foundation
import UIKit

class MasterViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
  
  // MARK: UIViewControllerTransitioningDelegate
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return self
  }
  
  // MARK: UIViewControllerAnimatedTransitioning
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 2
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    // ** Add your custom animation logic here **
  }
  
  @IBAction func transitionButtonPressed(_ sender: Any) {
    
    let vc = storyboard!.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
//    vc.transitioningDelegate = self
    present(vc, animated: true, completion: nil)
  }
}


class ModalViewController: UIViewController {
  //
  
  @IBAction func dismiss(_ sender: Any) {
    
    self.dismiss(animated: true, completion: nil)
  }
}
