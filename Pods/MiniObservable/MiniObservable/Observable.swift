import Foundation

// An Observable that can have more than 1 subscriber.
// Must have dispose bag mechanism to deallocate multiple subscribers.
public final  class Observable<T>: CustomStringConvertible {
  
  // Lock getter and setter of _value
  private let lock = NSRecursiveLock()
  
  // A callback that passes a generic value
  public typealias Event = (_ oldValue: T, _ newValue: T) -> Void
  
  // Observers to all events and changes
  public private(set) var observers = [UUID: Event]()
  
  public init(_ v: T) {
    _value = v
  }
  
  /// Observe any change in '_value'
  ///
  /// - Parameters:
  ///   - getLatest: get an immediately published event on subscribe.
  ///   - observer: an observer that listens to all changes
  ///   - Returns: the observer which can be disposed of when dispose bag observer is in becomes deallocated
  public func observe(getLatest: Bool = false, _ observer: @escaping Event)-> Disposable {
    
    let uniqueKey = UUID()
    observers[uniqueKey] = observer
    
    // Notify current observer about current value on initial subscribe.
    if getLatest {
      observer(_value, _value)
    }
    
    return Observer(owner: self, key: uniqueKey)
  }
  
  
  // Notify all observers that the observed value has been set
  private func updateObservers(oldValue: T, newValue: T) {
    for (_, observer) in observers {
      // iterate over all observers,
      // and call closure with new value.
      observer(oldValue, newValue)
    }
  }
  
  // Store reference of wrapped value
  private var _value: T
  
  public var value: T {
    get {
      lock.lock()
      defer { lock.unlock() }
      return _value
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      
      let oldValue = _value
      
      _value = newValue
      
      updateObservers(oldValue: oldValue, newValue: newValue)
    }
  }
  
  deinit {
    #if DEBUG
      print("Deallocating Observables")
    #endif
  }
  
  public func removeObserver(with key: UUID) {
    if observers.keys.contains(key) {
      observers.removeValue(forKey: key)
    }
  }
  
  public var description: String {
    return "Observable with current value: \(value)"
  }
}





