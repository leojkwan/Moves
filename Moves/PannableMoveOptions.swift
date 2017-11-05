
public enum PannableMoveDirection {
    case vertical
    case horizontal
    case free
}

public struct PannableMoveOptions {
    static public func defaultOptions() -> PannableMoveOptions {
        return PannableMoveOptions(
            direction: PannableMoveDirection.free,
            dismissRadiusThreshold: 50,
            lockedDirections: []
        )
    }
    
    public let direction: PannableMoveDirection
    public let dismissRadiusThreshold: CGFloat
    public let lockedDirections: [Direction]
    
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

