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

open class Navigator: NavigatorType {
    open let matcher = URLMatcher()
    open weak var delegate: NavigatorDelegate?
    
    private var viewControllerFactories = [URLPattern: ViewControllerFactory]()
    private var handlerFactories = [URLPattern: URLOpenHandlerFactory]()
    
    public init() {
        // ⛵ I'm a Navigator!
    }
    
    open func register(_ pattern: URLPattern, _ factory: @escaping ViewControllerFactory) {
        if self.viewControllerFactories[pattern] != nil {
            debugPrint("!!! Navigator Warning: Replacing route for URL - \(pattern)")
        }
        self.viewControllerFactories[pattern] = factory
    }
    
    open func handle(_ pattern: URLPattern, _ factory: @escaping URLOpenHandlerFactory) {
        self.handlerFactories[pattern] = factory
    }
    
    open func viewController(for url: URLConvertible, context: Any? = nil) -> UIViewController? {
        let urlPatterns = Array(self.viewControllerFactories.keys)
        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
        guard let factory = self.viewControllerFactories[match.pattern] else { return nil }
        return factory(url, match.values, context)
    }
    
    open func handler(for url: URLConvertible, context: Any?) -> URLOpenHandler? {
        let urlPatterns = Array(self.handlerFactories.keys)
        guard let match = self.matcher.match(url, from: urlPatterns) else { return nil }
        guard let handler = self.handlerFactories[match.pattern] else { return nil }
        return { handler(url, match.values, context) }
    }
}
