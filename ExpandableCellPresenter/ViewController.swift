//
//  ViewController.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 28.03.2023.
//

import UIKit

struct ContentItem {
    let title: String
    let text: String
    let longText: String
}

class ViewController: UIViewController {
    private var content = [ContentItem]()
    private let contentListView = ContentListView()

    override public func loadView() {
        view = contentListView
        contentListView.tableView.dataSource = self
        contentListView.tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let items = (0..<40).map {
            ContentItem(
                title: "Title \($0)",
                text: "Some text here",
                longText: String(repeating: "Long text ", count: 100)
            )
        }
        content.append(contentsOf: items)
    }

    private func presentFullContent(at indexPath: IndexPath) {
        let item = content[indexPath.row]

        let presenter = ExpandingCellPresenter(
            tableView: contentListView.tableView,
            indexPath: indexPath
        )

        let fullContentView = FullContentView()
        fullContentView.compactView.titleLabel.text = item.title
        fullContentView.compactView.textLabel.text = item.text
        fullContentView.longTextLabel.text = item.longText
        fullContentView.onCloseTapped = {
            do {
                try presenter.dismiss(adjustingScrollView: fullContentView.scrollView)
            } catch {
                print(error)
            }
        }

        do {
            try presenter.presentView(fullContentView)
        } catch {
            print(error)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContentCell.reuseIdentifier, for: indexPath) as! ContentCell
        let item = content[indexPath.row]
        let contentView = CompactContentView()
        contentView.titleLabel.text = item.title
        contentView.textLabel.text = item.text
        cell.view = contentView
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentFullContent(at: indexPath)
    }
}
