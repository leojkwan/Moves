
public enum PannableMoveDirection {
    case vertical
    case horizontal
    case free
}

public struct PannableConfiguration {
    static public func defaultOptions() -> PannableConfiguration {
        return PannableConfiguration(
            direction: PannableMoveDirection.free,
            dismissRadiusThreshold: 50,
            lockedDirections: []
        )
    }
    
    public var direction: PannableMoveDirection
    public var dismissRadiusThreshold: CGFloat
    public var lockedDirections: [Direction]
    
    public init(
        direction: PannableMoveDirection,
        dismissRadiusThreshold: CGFloat,
        lockedDirections: [Direction]
        ) {
        self.direction = direction
        self.dismissRadiusThreshold = dismissRadiusThreshold
        self.lockedDirections = lockedDirections
    }
}

