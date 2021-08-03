//
//  Queue.swift
//  Queue
//
//  Created by Stuart Rankin on 7/18/21. Adapted from Flatland View.
//

import Foundation
import UIKit

/// Implements a simple generic queue.
class Queue<T>
{
    /// Initializer.
    init()
    {
        Q = [T]()
    }
    
    /// Initializer.
    /// - Warning: If the number of items enqueued surpasses the maximum capacity, the items on the bottom of
    ///            the queue are silently discarded.
    /// - Parameter WithCapacity: The maximum capacity of the queue.
    init(WithCapacity: Int)
    {
        MaximumCapacity = WithCapacity
        Q = [T]()
    }
    
    /// Initializer.
    /// - Parameter Other: The other queue to use to populate this instance.
    init(_ Other: Queue<T>)
    {
        MaximumCapacity = Other.MaximumCapacity
        Q = [T]()
        let OtherItems = Other.AsArray()
        for SomeItem in OtherItems
        {
            Enqueue(SomeItem)
        }
    }
    
    /// Adjusts the contents of the queue when the maximum capacity is changed. If the number of items in
    /// the queue is less than the maximum capacity, no changes are made. If the number of items in the
    /// queue is greater than the maximum capacity, the earliest items are discarded.
    /// - Parameter Max: The maximum capacity for the queue.
    private func AdjustForMaximumCapacity(_ Max: Int)
    {
        if Q == nil
        {
            return
        }
        if Q!.count <= Max
        {
            return
        }
        let RemoveCount = Q!.count - Max
        Q!.removeLast(RemoveCount)
    }
    
    /// Holds the maximum capacity of the queue.
    private var _MaximumCapacity: Int = Int.max
    {
        didSet
        {
            AdjustForMaximumCapacity(_MaximumCapacity)
        }
    }
    /// Get or set the maximum capacity of the queue.
    /// - Warning: Setting a maximum capacity value less than the current capacity will cause the items
    ///            at the bottom of the queue to be discarded.
    public var MaximumCapacity: Int
    {
        get
        {
            return _MaximumCapacity
        }
        set
        {
            _MaximumCapacity = newValue
        }
    }
    
    /// Holds the queue's data.
    private var Q: [T]? = nil
    
    /// Clear the contents of the queue.
    public func Clear()
    {
        Q?.removeAll()
    }
    
    /// Returns the number of items in the queue.
    public var Count: Int
    {
        get
        {
            return Q!.count
        }
    }
    
    /// Returns true if the queue is empty, false if not.
    public var IsEmpty: Bool
    {
        get
        {
            return Q!.count == 0
        }
    }
    
    /// Enqueue the passed item.
    /// - Warning: If the caller tries to enqueue an item when the queue is at capacity (see `MaximumCapacity`),
    ///            items at the bottom of the queue will be discarded.
    public func Enqueue(_ Item: T)
    {
        //See if we need to make room for the new item.
        if Q!.count >= MaximumCapacity
        {
            let RemoveCount = Q!.count - MaximumCapacity + 1
            Q?.removeLast(RemoveCount)
        }
        Q?.append(Item)
    }
    
    /// Dequeue the oldest item in the queue. Nil returned if the queue is empty.
    public func Dequeue() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        let First = Q?.first
        Q?.removeFirst()
        return First
    }
    
    /// Peek at the next item to be dequeued but don't remove it from the queue. Nil returned if
    /// the queue is emtpy.
    public func DequeuePeek() -> T?
    {
        if Q!.count < 1
        {
            return nil
        }
        return Q?.first
    }
    
    /// Read the queue at the specified index. Nil return if the queue is empty or the value of `Index` is
    /// out of bounds.
    subscript(Index: Int) -> T?
    {
        get
        {
            if Count < 1
            {
                return nil
            }
            if Index < 0
            {
                return nil
            }
            if Index > Count - 1
            {
                return nil
            }
            return Q?[Index]
        }
    }
    
    /// Return the contents of the queue as an array.
    /// - Returns: Contents of the queue as an array.
    public func AsArray() -> [T]
    {
        var Results = [T]()
        for SomeT in Q!
        {
            Results.append(SomeT)
        }
        return Results
    }
    
    /// Remove items in the queue that meet the conditions in the closure.
    /// - Parameter Where: The closure that determines what will be removed.
    public func Remove(Where: (T) -> Bool)
    {
        if Q == nil
        {
            return
        }
        Q!.removeAll(where: {Where($0)})
    }
}
