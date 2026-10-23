//
//  OperationQueue.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 21/10/26.
//

import UIKit

class OperationQueueViewController: UIViewController {

    // MARK: - Properties

    private let urls: [URL] = (1...100).compactMap {
        URL(string: "https://picsum.photos/id/\($0)/300/450")
    }

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(OperationQueueCell.self, forCellReuseIdentifier: OperationQueueCell.reuseIdentifier)
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupAppbar()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OperationQueueImageLoader.shared.cancelAllQueue()
    }

    deinit {                                                 
        print("OperationQueueViewController dihapus")
    }

    // MARK: - Setup Appbar

    private func setupAppbar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemIndigo
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    // MARK: - Setup Layout

    private func setupLayout() {
        view.addSubview(tableView)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension OperationQueueViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        urls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OperationQueueCell.reuseIdentifier,
            for: indexPath
        ) as? OperationQueueCell else {
            return UITableViewCell()
        }
        cell.configure(with: "Poster-\(indexPath.row + 1)", imageURL: urls[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension OperationQueueViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("indexPath: \(indexPath.row)")
    }
}
