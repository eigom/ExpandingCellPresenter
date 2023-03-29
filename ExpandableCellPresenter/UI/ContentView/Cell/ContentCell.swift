//
//  ContentCell.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 28.03.2023.
//

import UIKit
import PureLayout

class ContentCell: UITableViewCell {
    var view: CompactContentView? {
        didSet {
            guard let view = view else {
                contentView.subviews.first?.removeFromSuperview()
                return
            }

            contentView.addSubview(view)
            view.autoPinEdgesToSuperviewEdges()
        }
    }

    static let reuseIdentifier = String(describing: ContentCell.self)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        view = nil
    }

    private func setup() {
        selectionStyle = .none
    }

    private func layout() {}
}

