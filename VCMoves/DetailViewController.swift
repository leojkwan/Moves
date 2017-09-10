//
//  DetailViewController.swift
//  VCMoves
//
//  Created by Leo Kwan on 9/7/17.
//  Copyright © 2017 Leo Kwan. All rights reserved.
//

import Foundation
import UIKit
import Moves

public class DetailViewController: UIViewController {
  
  @IBOutlet public var detailItem: UIView!
  
  @IBAction func dismiss(_ sender: Any) {
    
    self.dismiss(animated: true, completion: nil)
  }
  
  deinit {
    print("deallocating")
  }
  override public func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override public func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
}
