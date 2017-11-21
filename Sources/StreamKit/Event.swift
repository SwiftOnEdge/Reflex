//
//  Event.swift
//  Edge
//
//  Created by Tyler Fleming Cloutier on 5/29/16.
//
//

import Foundation

/// Represents a signal event.
///
/// Signals must conform to the grammar:
/// `next* (failed | completed | interrupted)?`
public enum Event<Value> {
    
    /// A value provided by the signal.
    case next(Value)
    
    /// The signal terminated because of an error. No further events will be
    /// received.
    case failed(Error)
    
    /// The signal successfully terminated. No further events will be received.
    case completed
    
    /// Event production on the signal has been interrupted. No further events
    /// will be received.
    case interrupted
    
    
    /// Whether this event indicates signal termination (i.e., that no further
    /// events will be received).
    public var isTerminating: Bool {
        switch self {
        case .next:
            return false
            
        case .failed, .completed, .interrupted:
            return true
        }
    }
    
    /// Lifts the given function over the event's value.
    public func map<U>(_ f: (Value) -> U) -> Event<U> {
        switch self {
        case let .next(value):
            return .next(f(value))
            
        case let .failed(error):
            return .failed(error)
            
        case .completed:
            return .completed
            
        case .interrupted:
            return .interrupted
        }
    }
    
    /// Lifts the given function over the event's value.
    public func flatMap<U>(_ f: (Value) -> U?) -> Event<U>? {
        switch self {
        case let .next(value):
            if let nextValue = f(value) {
                return .next(nextValue)
            }
            return nil
            
        case let .failed(error):
            return .failed(error)
            
        case .completed:
            return .completed
            
        case .interrupted:
            return .interrupted
        }
    }
    
    /// Lifts the given function over the event's error.
    public func mapError<F: Error>(_ f: (Error) -> F) -> Event<Value> {
        switch self {
        case let .next(value):
            return .next(value)
            
        case let .failed(error):
            return .failed(f(error))
            
        case .completed:
            return .completed
            
        case .interrupted:
            return .interrupted
        }
    }
    
    /// Unwraps the contained `Next` value.
    public var value: Value? {
        if case let .next(value) = self {
            return value
        } else {
            return nil
        }
    }
    
    /// Unwraps the contained `Error` value.
    public var error: Error? {
        if case let .failed(error) = self {
            return error
        } else {
            return nil
        }
    }
}

public func == <Value: Equatable> (lhs: Event<Value>, rhs: Event<Value>) -> Bool {
    switch (lhs, rhs) {
    case let (.next(left), .next(right)):
        return left == right
        
    case let (.failed(left), .failed(right)):
        return left.localizedDescription == right.localizedDescription
        
    case (.completed, .completed):
        return true
        
    case (.interrupted, .interrupted):
        return true
        
    default:
        return false
    }
}

