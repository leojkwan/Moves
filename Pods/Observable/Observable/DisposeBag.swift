import Foundation

// A bag holding items to disposed on deinitialization.
public class DisposeBag {
  
  private(set) var disposables: [Disposable] = []
  
  public func add(_ disposable: Disposable) {
    disposables.append(disposable)
  }
  
  func dispose() {
    disposables.forEach({
      #if DEBUG
        print("Disposing \($0)")
      #endif
      $0.dispose()
    })
  }
  
  public init() {}
  
  // When our view controller deinits, our dispose bag will deinit as well
  // and trigger the disposal of all corresponding observers living in the
  // Observable, which Disposable has a weak reference to: 'owner'.
  deinit {
    dispose()
  }
}

// An item that can be removed.
public protocol Disposable {
  func dispose()
}

extension Disposable {
  public func disposed(by bag: DisposeBag) {
    bag.add(self)
  }
}
