//
//  FullContentView.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 28.03.2023.
//

import UIKit

class FullContentView: UIView {
    let compactView = CompactContentView()
    let scrollView = UIScrollView()
    var onCloseTapped: (() -> Void)?

    private let stackView = UIStackView()
    private let longTextLabel = UILabel()
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
        stackView.spacing = 30

        longTextLabel.font = .systemFont(ofSize: 16)

        closeButton.setTitle("CLOSE", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()

        scrollView.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        stackView.autoMatch(.width, to: .width, of: scrollView)
        NSLayoutConstraint.autoSetPriority(.defaultLow) {
            stackView.autoMatch(.height, to: .height, of: scrollView)
        }

        stackView.addArrangedSubview(compactView)
        stackView.addArrangedSubview(longTextLabel)
        stackView.addArrangedSubview(closeButton)
    }

    @objc
    private func closeTapped() {
        onCloseTapped?()
    }
}
