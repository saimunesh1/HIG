//
//  RenderNotifyingTableViewCell.swift
//  The General
//
//  Created by Blanco, John (US - Denver) on 1/17/18.
//  Copyright © 2018 The General. All rights reserved.
//

import UIKit

// RenderNotifyingTableViewCell is useful when you need to know when a cell has been
// rendered/added to a UITableView. This is immediately handy
// when you are dynamically measuring the height of a table view's content.
//
// When the cell is added to the UITableView, it might not immediately be hooked
// up to the table's visibleCells, therefore the callback requires a return
// of true before it stops notifying. Returning false means
// the callback will come again shortly.

class RenderNotifyingTableViewCell: UITableViewCell {
    var onRenderFinished: (() -> (Bool))?
    
    private var renderedTimer: Timer?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        startTimer()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        startTimer()
    }
    
    @objc private func renderedTimerFired(_ timer: Timer) {
        if let onRenderFinished = onRenderFinished {
            if onRenderFinished() {
                stopTimer()
            }
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        renderedTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(renderedTimerFired(_:)), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        renderedTimer?.invalidate()
        renderedTimer = nil
    }
}
