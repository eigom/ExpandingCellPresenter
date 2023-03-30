//
//  ExpandingCellPresenter.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 29.03.2023.
//

import UIKit

class ExpandingCellPresenter: UIView {
    enum Error: Swift.Error {
        case tableViewHasNoParent
        case failedToSnapshot
        case notPresented
    }

    private struct Frames {
        let top: CGRect
        let middle: CGRect
        let bottom: CGRect
    }

    private struct SnapshotViews {
        let topView: UIView
        let bottomView: UIView

        func attach(to view: UIView, in parentView: UIView) {
            parentView.addSubview(topView)
            topView.autoPinEdge(.bottom, to: .top, of: view)
            topView.autoPinEdge(.left, to: .left, of: view)
            topView.autoPinEdge(.right, to: .right, of: view)

            parentView.addSubview(bottomView)
            bottomView.autoPinEdge(.top, to: .bottom, of: view)
            bottomView.autoPinEdge(.left, to: .left, of: view)
            bottomView.autoPinEdge(.right, to: .right, of: view)
        }

        func removeFromSuperview() {
            topView.removeFromSuperview()
            bottomView.removeFromSuperview()
        }
    }

    var presentationDuration: TimeInterval = 0.5
    var dismissDuration: TimeInterval = 0.5
    var presentationOptions: UIView.AnimationOptions = [.curveEaseIn]
    var dismissOptions: UIView.AnimationOptions = [.curveEaseIn]

    private let tableView: UITableView
    private let indexPath: IndexPath
    private var presentedView: UIView?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

    private var snapshotFrames: Frames {
        let cellRect = tableView.convert(
            tableView.rectForRow(at: indexPath),
            to: tableView
        )
        let middle = CGRect(
            origin: CGPoint(
                x: cellRect.origin.x,
                y: cellRect.origin.y - tableView.contentOffset.y
            ),
            size: cellRect.size
        )
        let top = CGRect(
            origin: CGPoint(
                x: 0,
                y: tableView.contentOffset.y
            ),
            size: CGSize(
                width: middle.size.width,
                height: middle.origin.y
            )
        )
        let bottom = CGRect(
            origin: CGPoint(
                x: 0,
                y: middle.maxY + tableView.contentOffset.y
            ),
            size: CGSize(
                width: middle.size.width,
                height: tableView.frame.height - middle.maxY
            )
        )

        return Frames(top: top, middle: middle, bottom: bottom)
    }

    init(tableView: UITableView, indexPath: IndexPath) {
        self.tableView = tableView
        self.indexPath = indexPath
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    func presentView(_ view: UIView, animated: Bool = true) -> Result<Void, Error> {
        guard let presentingView = tableView.superview else { return .failure(.tableViewHasNoParent) }
        guard let snapshotViews = makeSnapshotViews(of: tableView, using: snapshotFrames) else { return .failure(.failedToSnapshot) }

        presentingView.insertSubview(self, aboveSubview: tableView)
        autoPinEdge(.left, to: .left, of: tableView)
        autoPinEdge(.right, to: .right, of: tableView)
        autoPinEdge(.top, to: .top, of: tableView)
        autoPinEdge(.bottom, to: .bottom, of: tableView)

        addSubview(view)
        view.autoPinEdge(toSuperviewEdge: .left)
        view.autoPinEdge(toSuperviewEdge: .right)
        topConstraint = view.autoPinEdge(toSuperviewEdge: .top, withInset: snapshotFrames.middle.origin.y)
        bottomConstraint = view.autoPinEdge(toSuperviewEdge: .bottom, withInset: snapshotFrames.bottom.height)

        snapshotViews.attach(to: view, in: self)

        layoutIfNeeded()

        topConstraint?.constant = 0
        bottomConstraint?.constant = 0

        if animated {
            UIView.animate(
                withDuration: presentationDuration,
                delay: 0.0,
                options: presentationOptions)
            {
                self.layoutIfNeeded()
            } completion: { _ in
                snapshotViews.removeFromSuperview()
            }
        } else {
            snapshotViews.removeFromSuperview()
        }

        presentedView = view

        return .success(())
    }

    @discardableResult
    func dismiss(animated: Bool = true, adjustingScrollView: UIScrollView? = nil) -> Result<Void, Error> {
        guard let view = presentedView else { return .failure(.notPresented) }
        guard let snapshotViews = makeSnapshotViews(of: tableView, using: snapshotFrames) else { return .failure(.failedToSnapshot) }

        snapshotViews.attach(to: view, in: self)

        layoutIfNeeded()

        topConstraint?.constant = snapshotFrames.middle.origin.y
        bottomConstraint?.constant = -snapshotFrames.bottom.height

        adjustingScrollView?.setContentOffset(.zero, animated: animated)

        if animated {
            UIView.animate(
                withDuration: dismissDuration,
                delay: 0.0,
                options: dismissOptions) {
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.removeFromSuperview()
                }
        } else {
            removeFromSuperview()
        }

        return .success(())
    }

    private func setup() {
        clipsToBounds = true
    }

    private func makeSnapshotViews(of view: UIView, using frames: Frames) -> SnapshotViews? {
        guard let topView = makeSnapshotView(of: view, using: frames.top) else { return nil }
        guard let bottomView = makeSnapshotView(of: view, using: frames.bottom) else { return nil }

        return SnapshotViews(topView: topView, bottomView: bottomView)
    }

    private func makeSnapshotView(of view: UIView, using frame: CGRect) -> UIView? {
        let snapshotView = view.resizableSnapshotView(
            from: frame,
            afterScreenUpdates: false,
            withCapInsets: .zero
        )
        snapshotView?.autoSetDimension(.height, toSize: frame.size.height)

        return snapshotView
    }
}
