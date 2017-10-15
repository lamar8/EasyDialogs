//
// Copyright (c) 2017 Marco Conti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


import Foundation

public class ObjectFormWindow<VALUE: EmptyInit & Equatable>: FormWindow {
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let bindings: [AnyObjectInputBinding<VALUE>]
    
    public init(
        bindings: [AnyObjectInputBinding<VALUE>],
        headerText: String? = nil,
        minFormHeight: CGFloat = 200,
        onConfirm: @escaping (VALUE?) -> (),
        value: VALUE? = nil
        )
    {
        self.bindings = bindings
        super.init(
            inputs: bindings.map { $0.input },
            headerText: headerText,
            minFormHeight: minFormHeight,
            onConfirm: { false })
        self.onConfirm = { [weak self] in
            guard let `self` = self else { return false }
            if let newValue = self.createObject(initialValue: value) {
                onConfirm(newValue)
                return true
            }
            return false
        }
    }
    
    private func createObject(initialValue: VALUE?) -> VALUE? {
        
        var object = initialValue ?? VALUE()
        do {
            try self.bindings.forEach {
                try $0.write(on: &object)
            }
        } catch let error as UnexpectedNilValueError {
            self.showError(error)
            return nil
        } catch {
            return nil
        }
        return object
    }
    
    private func showError(_ error: UnexpectedNilValueError) {
        // TODO: show error on UI
    }
}

extension BindingsFactory where Object: Equatable & EmptyInit {
    
    public func formWindowForEditClosure(
        headerText: String? = nil
        ) -> ObjectListInput<Object>.ObjectEditHandler {
        
        let bindings = self.bindings
        return { value, callback in
            // spawn a window and invoke callback on confirm/cancel
            let concreteBindings = bindings.map { $0() }
            concreteBindings.forEach {
                $0.read(from: value)
            }
            ObjectFormWindow(
                bindings: concreteBindings,
                headerText: headerText,
                onConfirm: { callback($0) },
                value: value).present()
        }
    }
    
    public func formWindowForCreationClosure(
        headerText: String? = nil
        ) -> ObjectListInput<Object>.ObjectCreationHandler {
        
        let bindings = self.bindings
        return { callback in
            // spawn a window and invoke callback on confirm/cancel
            ObjectFormWindow(
                bindings: bindings.map { $0() },
                headerText: headerText,
                onConfirm: { callback($0) },
                value: nil).present()
        }
    }
}

