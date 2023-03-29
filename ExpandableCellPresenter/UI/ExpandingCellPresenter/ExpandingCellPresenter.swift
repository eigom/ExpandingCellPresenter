//
//  ExpandingCellPresenter.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 29.03.2023.
//

// TODO: expose anim params
// try snapshot view taking methods

import UIKit

class ExpandingCellPresenter: UIView {
    enum Failure: Error {
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
            topView.autoAlignAxis(.vertical, toSameAxisOf: view)

            parentView.addSubview(bottomView)
            bottomView.autoPinEdge(.top, to: .bottom, of: view)
            bottomView.autoAlignAxis(.vertical, toSameAxisOf: view)
        }

        func removeFromSuperview() {
            topView.removeFromSuperview()
            bottomView.removeFromSuperview()
        }
    }

    var presentationDuration: TimeInterval = 2.5
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
            origin: .zero,
            size: CGSize(
                width: middle.size.width,
                height: middle.origin.y
            )
        )
        let bottom = CGRect(
            origin: CGPoint(
                x: 0,
                y: middle.maxY
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
    func presentView(_ view: UIView, animated: Bool = true) -> Result<Void, Failure> {
        guard let presentingView = tableView.superview else { return .failure(.tableViewHasNoParent) }
        guard let snapshot = takeSnapshot(of: tableView) else { return .failure(.failedToSnapshot) }

        presentingView.insertSubview(self, aboveSubview: tableView)
        autoPinEdge(.leading, to: .leading, of: tableView)
        autoPinEdge(.trailing, to: .trailing, of: tableView)
        autoPinEdge(.top, to: .top, of: tableView)
        autoPinEdge(.bottom, to: .bottom, of: tableView)

        addSubview(view)
        view.autoPinEdge(toSuperviewEdge: .leading)
        view.autoPinEdge(toSuperviewEdge: .trailing)
        topConstraint = view.autoPinEdge(toSuperviewEdge: .top, withInset: snapshotFrames.middle.origin.y)
        bottomConstraint = view.autoPinEdge(toSuperviewEdge: .bottom, withInset: snapshotFrames.bottom.height)

        let snapshotViews = makeSnapshotViews(from: snapshot, using: snapshotFrames)
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
    func dismiss(animated: Bool = true, adjustingScrollView: UIScrollView? = nil) -> Result<Void, Failure> {
        guard let view = presentedView else { return .failure(.notPresented) }
        guard let snapshot = takeSnapshot(of: tableView) else { return .failure(.failedToSnapshot) }

        let snapshotViews = makeSnapshotViews(from: snapshot, using: snapshotFrames)
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

    private func takeSnapshot(of tableView: UITableView) -> CGImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(tableView.bounds.size, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: 0, y: -tableView.contentOffset.y)
        tableView.layer.render(in: context)

        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }

    private func makeSnapshotViews(from image: CGImage, using frames: Frames) -> SnapshotViews {
        let topView = cropSnapshotView(from: image, with: frames.top) ?? makeEmptySnapshotView(width: image.width)
        let bottomView = cropSnapshotView(from: image, with: frames.bottom) ?? makeEmptySnapshotView(width: image.width)

        return SnapshotViews(topView: topView, bottomView: bottomView)
    }

    private func cropSnapshotView(from image: CGImage, with frame: CGRect) -> UIView? {
        let scale = UIScreen.main.scale
        let scaledRect = frame * scale

        guard let cropped = image.cropping(to: scaledRect) else { return nil }

        let image = UIImage(cgImage: cropped, scale: UIScreen.main.scale, orientation: .up)
        let imageView = UIImageView(image: image)
        imageView.autoSetDimensions(to: image.size)

        return imageView
    }

    private func makeEmptySnapshotView(width: Int) -> UIView {
        let view = UIView()
        view.autoSetDimensions(to: CGSize(width: width, height: 0))

        return view
    }
}

extension CGRect {
    static func *(rect: CGRect, multiplier: CGFloat) -> CGRect {
        return CGRect(
            origin: CGPoint(
                x: rect.origin.x * multiplier,
                y: rect.origin.y * multiplier
            ),
            size: CGSize(
                width: rect.size.width * multiplier,
                height: rect.size.height * multiplier
            )
        )
    }
}
