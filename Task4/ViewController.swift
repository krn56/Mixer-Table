//
//  ViewController.swift
//  Task4
//
//  Created by Роман Крендясов on 10.11.2024.
//

import UIKit

class ViewController: UIViewController {
    
    private typealias DiffableDataSource = UITableViewDiffableDataSource<Int, Int>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Int>
    
    private let reuseIdentifier = "Cell"
    private lazy var tableView = makeTableView()
    private var tableData = Array(0...30)
    private var checkedNumbers: Set<Int> = []
    private var dataSource: DiffableDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleTable))
        view.backgroundColor = .systemBackground
        makeDataSource()
        view.addSubview(tableView)
        apply()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.frame
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let isChecked = cell.accessoryType != .none
        if isChecked {
            checkedNumbers.remove(tableData[indexPath.row])
            cell.accessoryType = .none
        }
        else {
            let element = tableData.remove(at: indexPath.row)
            tableData.insert(element, at: 0)
            checkedNumbers.insert(element)
            cell.accessoryType = .checkmark
            apply()
        }
    }
}

private extension ViewController {
    func makeTableView() -> TableView {
        let tableView = TableView(frame: .zero, style: .insetGrouped)
        tableView.register(TableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        return tableView
    }
    
    func makeDataSource() {
        dataSource = DiffableDataSource(tableView: tableView) { [unowned self] tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
            let isChecked = self.checkedNumbers.contains(itemIdentifier)
            
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "\(itemIdentifier)"
            cell.contentConfiguration = configuration
            cell.accessoryType = isChecked ? .checkmark : .none
            
            return cell
        }
        tableView.dataSource = dataSource
    }
    
    @objc func shuffleTable() {
        tableData.shuffle()
        apply()
    }
    
    func apply() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(tableData, toSection: 0)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

#Preview {
    ViewController()
}


class TableView: UITableView {
    override func reloadData() {
        super.reloadData()
        UIView.transition(with: self, duration: 1, options: .transitionCrossDissolve) {
            super.reloadData()
        }
    }
}

class TableViewCell: UITableViewCell {}
