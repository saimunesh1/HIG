//
//  Overlayable.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/8/18.
//  Copyright © 2018 The General. All rights reserved.
//

import Foundation

protocol Overlayable: class where Self: UIViewController  {
    var onDidTouchAnywhere: (() -> ())? { get set }
}
