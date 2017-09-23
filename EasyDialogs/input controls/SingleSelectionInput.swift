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


import Cocoa
import Cartography

public class SingleSelectionInput<VALUE: Equatable>: ValueInput<VALUE, NSComboBox> {
    
    public init(label: String?,
                     values: [VALUE],
                     valueToDisplay: ((VALUE)->Any)? = nil,
                     value: VALUE? = nil,
                     validationRules: [AnyInputValidation<VALUE>] = [])
    {
        let combo = NSComboBox()
        combo.isEditable = false
        values.forEach {
            let itemToDisplay: Any
            if let valueToDisplay = valueToDisplay {
                itemToDisplay = valueToDisplay($0)
            } else {
                itemToDisplay = $0
            }
            combo.addItem(withObjectValue: itemToDisplay)
        }
        
        super.init(
            label: label,
            value: value,
            controlView: combo,
            valueExtraction: { control in
                let index = control.indexOfSelectedItem
                guard index >= 0 else { return nil }
                return values[index]
            },
            setValue: { control, value in
                guard let value = value, let index = values.index(of: value) else { return }
                control.selectItem(at: index)
            },
            validationRules: validationRules
        )
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
}

protocol IdentityEquatable: class, Equatable { }

extension IdentityEquatable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}
