//
//  CwlDispatch.swift
//  CwlUtils
//
//  Created by Matt Gallagher on 2016/07/29.
//  Copyright © 2016 Matt Gallagher ( http://cocoawithlove.com ). All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation

public extension DispatchSource {
	// An overload of timer that immediately sets the handler and schedules the timer
    class func singleTimer(interval: DispatchTimeInterval, since time: DispatchTime = DispatchTime.now(), leeway: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue, handler: @escaping () -> Void) -> DispatchSourceTimer {
		let result = DispatchSource.makeTimerSource(queue: queue)
		result.setEventHandler(handler: handler)
        result.schedule(deadline: time + interval, leeway: leeway)
		result.resume()
		return result
	}
	
	// An overload of timer that always uses the default global queue (because it is intended to enter the appropriate mutex as a separate step) and passes a user-supplied Int to the handler function to allow ignoring callbacks if cancelled or rescheduled before mutex acquisition.
    class func singleTimer<T>(parameter: T, interval: DispatchTimeInterval, since time: DispatchTime = DispatchTime.now(), leeway: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue = DispatchQueue.global(), handler: @escaping (T) -> Void) -> DispatchSourceTimer {
		let result = DispatchSource.makeTimerSource(queue: queue)
        result.scheduleOneshot(parameter: parameter, interval: interval, since: time, leeway: leeway, handler: handler)
		result.resume()
		return result
	}

	// An overload of timer that immediately sets the handler and schedules the timer
    class func repeatingTimer(interval: DispatchTimeInterval, since time: DispatchTime = DispatchTime.now(), leeway: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue = DispatchQueue.global(), handler: @escaping () -> Void) -> DispatchSourceTimer {
		let result = DispatchSource.makeTimerSource(queue: queue)
		result.setEventHandler(handler: handler)
        result.schedule(deadline: time + interval, repeating: interval, leeway: leeway)
		result.resume()
		return result
	}
	
	// An overload of timer that always uses the default global queue (because it is intended to enter the appropriate mutex as a separate step) and passes a user-supplied Int to the handler function to allow ignoring callbacks if cancelled or rescheduled before mutex acquisition.
    class func repeatingTimer<T>(parameter: T, interval: DispatchTimeInterval, since time: DispatchTime = DispatchTime.now(), leeway: DispatchTimeInterval = .nanoseconds(0), queue: DispatchQueue = DispatchQueue.global(), handler: @escaping (T) -> Void) -> DispatchSourceTimer {
		let result = DispatchSource.makeTimerSource(queue: queue)
        result.scheduleRepeating(parameter: parameter, interval: interval, since: time, leeway: leeway, handler: handler)
		result.resume()
		return result
	}
}

public extension DispatchSourceTimer {
	// An overload of scheduleOneshot that updates the handler function with a new user-supplied parameter when it changes the expiry deadline
    func scheduleOneshot<T>(parameter: T, interval: DispatchTimeInterval, since time: DispatchTime = DispatchTime.now(),leeway: DispatchTimeInterval = .nanoseconds(0), handler: @escaping (T) -> Void) {
		suspend()
		setEventHandler { handler(parameter) }
        schedule(deadline: time + interval, leeway: leeway)
		resume()
	}
	
	// An overload of scheduleOneshot that updates the handler function with a new user-supplied parameter when it changes the expiry deadline
    func scheduleRepeating<T>(parameter: T, interval: DispatchTimeInterval, since time: DispatchTime = DispatchTime.now(), leeway: DispatchTimeInterval = .nanoseconds(0), handler: @escaping (T) -> Void) {
		suspend()
		setEventHandler { handler(parameter) }
        schedule(deadline: time + interval, repeating: interval, leeway: leeway)
		resume()
	}
}

public extension DispatchTime {
    func since(_ previous: DispatchTime) -> DispatchTimeInterval {
        let difference = Int64(uptimeNanoseconds) - Int64(previous.uptimeNanoseconds)
		return .nanoseconds(Int(difference))
	}
}

public extension DispatchTimeInterval {
    
    static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
		return .nanoseconds(Int(seconds * Double(NSEC_PER_SEC)))
	}

    var inSeconds: Double {
		switch self {
		case .seconds(let t):
            return Double(t)
		case .milliseconds, .microseconds, .nanoseconds:
            return (1.0 / Double(NSEC_PER_SEC)) * Double(inNanoseconds)
        case .never:
            return Double.greatestFiniteMagnitude
        @unknown default:
            fatalError()
        }
	}

    var inNanoseconds: Int {
		switch self {
		case .seconds(let t): return Int(NSEC_PER_SEC) * t
		case .milliseconds(let t): return Int(NSEC_PER_MSEC) * t
		case .microseconds(let t): return Int(NSEC_PER_USEC) * t
		case .nanoseconds(let t): return t
        case .never: return Int.max
        @unknown default:
            fatalError()
        }
	}
}

public func ==(lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
    return lhs.inSeconds == rhs.inSeconds
}

extension DispatchTimeInterval: Comparable {}

public func < (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> Bool {
    return lhs.inSeconds < rhs.inSeconds
}

