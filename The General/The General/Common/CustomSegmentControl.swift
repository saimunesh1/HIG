//
//  CustomSegmentControl.swift
//  The General
//
//  Created by Moore, Michael (US - New York) on 10/4/17.
//  Copyright © 2017 Deloitte Digital. All rights reserved.
//

import UIKit

@IBDesignable class CustomSegmentControl: UIControl {

    private var labels = [UILabel]()

    var thumbView: UIView?
    var inset: CGFloat = 3.0
    var dividerThickness: CGFloat = 1.0
    var borderThicknes: CGFloat = 1.0
    
    var items: [String] = ["Item 1", "Item 2", "Item 3"] {
        didSet {
            DispatchQueue.main.async{ [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.setupLabels()
            }
        }
    }

    var selectedIndex: Int = -1 {
        didSet {
            if selectedIndex == -1 {
                thumbView?.removeFromSuperview()
                thumbView = nil
            } else {
                displayNewSelectedIndex()
            }
        }
    }

    @IBInspectable var selectedLabelColor: UIColor = .white {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable var unselectedLabelColor: UIColor = .tgGreen {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable var thumbColor: UIColor = .tgGreen {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable var borderColor: UIColor = .tgGreen {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    var font: UIFont! = UIFont(name: "OpenSans-SemiBold", size: 14.0) {
        didSet {
            setFont()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }

    func setupView() {

        layer.cornerRadius = frame.height / 2
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderThicknes
        layer.masksToBounds = true

        backgroundColor = .clear
        setupLabels()
        addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
    }

    func setupLabels() {

        for label in labels {
            label.removeFromSuperview()
        }

        labels.removeAll(keepingCapacity: true)

        for i in 0..<items.count {

            let label = UILabel()
            label.backgroundColor = .clear
            label.font = font
            label.sizeToFit()
            label.textAlignment = .center
            label.textColor = i == selectedIndex ? selectedLabelColor : unselectedLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false

            let attributedString = NSMutableAttributedString(string: items[i])
            attributedString.addAttribute(.kern, value: -0.5, range: NSRange(location: 0, length: attributedString.length))
            label.attributedText = attributedString

            self.addSubview(label)
            labels.append(label)
        }

        addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth

        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true

        displayNewSelectedIndex()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {

        let location = touch.location(in: self)

        var calculatedIndex: Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }

        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
		displayNewSelectedIndex()
        return false
    }

    func displayNewSelectedIndex() {
        for (index, item) in labels.enumerated() {

            item.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

            if index == selectedIndex {

                item.textColor = selectedLabelColor

                var thumbFrame = CGRect()

                switch index {
                case 0:
                    thumbFrame = CGRect(x: item.frame.origin.x + inset, y: item.frame.origin.y + inset, width: item.frame.width - inset, height: item.frame.height - (inset * 2))
                    break
                case labels.count - 1:
                    thumbFrame = CGRect(x: item.frame.origin.x, y: item.frame.origin.y + inset, width: item.frame.width - inset, height: item.frame.height - (inset * 2))
                default:
                    thumbFrame = CGRect(x: item.frame.origin.x + (inset / 2), y: item.frame.origin.y + inset, width: item.frame.width - inset, height: item.frame.height - (inset * 2))
                    break
                }

                if let thumbView = thumbView {
                    thumbView.frame = thumbFrame
                    thumbView.backgroundColor = thumbColor
                    thumbView.layer.cornerRadius = thumbView.frame.height / 2
                } else {
                    thumbView = UIView()
                    thumbView!.frame = thumbFrame
                    thumbView!.backgroundColor = thumbColor
                    thumbView!.layer.cornerRadius = thumbView!.frame.height / 2
					thumbView?.isUserInteractionEnabled = false
                    insertSubview(thumbView!, at: selectedIndex)
                    sendSubview(toBack: thumbView!)
                }

            } else {

                item.textColor = unselectedLabelColor

                switch selectedIndex {
                case labels.count - 1:
                    if index < labels.count - 2 {
                        item.layer.addRightBorder(color: .tgGray, thickness: dividerThickness, inset: inset)
                    }
                    break
                case index + 1:
                    break
                default:
                    if index < labels.count - 1 {
                        item.layer.addRightBorder(color: .tgGray, thickness: dividerThickness, inset: inset)
                    }
                }
            }
        }
    }

    func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {

        _ = mainView.constraints

        for (index, button) in items.enumerated() {

            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 0)

            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1.0, constant: 0)

            var rightConstraint: NSLayoutConstraint!

            if index == items.count - 1 {

                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1.0, constant: -padding)

            } else {

                let nextButton = items[index + 1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: .left, multiplier: 1.0, constant: -padding)
            }

            var leftConstraint: NSLayoutConstraint!

            if index == 0 {

                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1.0, constant: padding)

            } else {

                let prevButton = items[index - 1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevButton, attribute: .right, multiplier: 1.0, constant: padding)

                var widthConstraint: NSLayoutConstraint!
                let firstItem = items[0]

                if firstItem.frame.size.width > button.frame.size.width {
                    widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)
                } else {
                    widthConstraint = NSLayoutConstraint(item: firstItem, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0  , constant: 0)
                }

                mainView.addConstraint(widthConstraint)
            }

            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }

    func setSelectedColors() {
        for (index, item) in labels.enumerated() {
            if index != selectedIndex {
                item.textColor = unselectedLabelColor
            } else {
                item.textColor = selectedLabelColor
            }
        }
    }

    func setFont() {
        for item in labels {
            item.font = font
        }
    }
}
