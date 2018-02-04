// Copyright (c) 2016 Suyeol Jeon (xoul.kr)
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

import UIKit

public protocol NavigatorDelegate: class {
    /// Returns whether the navigator should push the view controller or not. It returns `true` for
    /// default.
    func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool
    
    /// Returns whether the navigator should present the view controller or not. It returns `true`
    /// for default.
    func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool
    
    func shouldReplace(viewController: UIViewController) -> Bool
}

extension NavigatorDelegate {
    public func shouldPush(viewController: UIViewController, from: UINavigationControllerType) -> Bool {
        return true
    }
    
    public func shouldPresent(viewController: UIViewController, from: UIViewControllerType) -> Bool {
        return true
    }
    
    public func shouldReplace(viewController: UIViewController) -> Bool {
        return true
    }
}
