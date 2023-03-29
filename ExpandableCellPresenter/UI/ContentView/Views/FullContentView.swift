//
//  FullContentView.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 28.03.2023.
//

import UIKit

class FullContentView: UIView {
    let compactView = CompactContentView()
    let longTextLabel = UILabel()
    let scrollView = UIScrollView()
    var onCloseTapped: (() -> Void)?

    private let stackView = UIStackView()
    private let contentView = UIView()
    private let closeButton = UIButton()

    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .white

        stackView.axis = .vertical
        stackView.spacing = 20

        longTextLabel.font = .systemFont(ofSize: 16)
        longTextLabel.numberOfLines = 0

        closeButton.backgroundColor = .blue
        closeButton.setTitle("CLOSE", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()

        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.autoMatch(.width, to: .width, of: scrollView)
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            contentView.autoMatch(.height, to: .height, of: scrollView)
        }

        contentView.addSubview(compactView)
        compactView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)

        contentView.addSubview(stackView)
        stackView.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        stackView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        stackView.autoPinEdge(.top, to: .bottom, of: compactView)
        stackView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0, relation: .greaterThanOrEqual)

        stackView.addArrangedSubview(longTextLabel)
        stackView.addArrangedSubview(closeButton)

        closeButton.autoSetDimension(.height, toSize: 40)
    }

    @objc
    private func closeTapped() {
        onCloseTapped?()
    }
}
