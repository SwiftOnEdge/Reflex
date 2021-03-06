//
//  Promise.swift
//  StreamKit
//
//  Created by Tyler Fleming Cloutier on 11/20/17.
//

import Foundation
import PromiseKit

extension Promise {

    public func asSignal() -> Signal<T> {
        // TODO: If the promise is already resolved the value will
        // be sent to the signals before there are any observers added.
        return Signal { observer in
            self.then { value -> () in
                observer.sendNext(value)
                observer.sendCompleted()
            }.catch { error in
                observer.sendFailed(error)
            }
            return nil
        }
    }

}

extension SignalType {

    public func asPromise() -> Promise<[Value]> {
        var values: [Value] = []
        return Promise { resolve, reject in
            self.onNext {
                values.append($0)
            }
            self.onCompleted {
                resolve(values)
            }
            self.onFailed {
                reject($0)
            }
        }
    }

}
