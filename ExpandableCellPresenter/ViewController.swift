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

    override public func loadView() {
        let view = ContentTableView()
        self.view = view
        bind(to: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let items = (0..<20).map {
            ContentItem(
                title: "Title \($0)",
                text: "Some text here",
                longText: String(repeating: "Long text ", count: 100)
            )
        }
        content.append(contentsOf: items)
    }

    private func bind(to view: ContentTableView) {
        view.tableView.dataSource = self
        view.tableView.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContentCell
        let content = content[indexPath.row]
        let contentView = CompactContentView()
        contentView.titleLabel.text = content.title
        contentView.textLabel.text = content.text
        cell.view = contentView
        return cell
    }
}

extension ViewController: UITableViewDelegate {

}
