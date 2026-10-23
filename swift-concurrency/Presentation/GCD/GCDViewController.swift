//
//  GCDViewController.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 21/10/26.
//

import UIKit

class GCDViewController: UIViewController {

    // MARK: - Properties

    private let urls: [URL] = (1...100).compactMap {
        URL(string: "https://picsum.photos/id/\($0)/300/450")
    }

    private var finishedCount = 0

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.register(GCDCell.self, forCellReuseIdentifier: GCDCell.reuseIdentifier)
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.text = "Mengunduh 0/100 (0%)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0
        progress.tintColor = .systemIndigo
        return progress
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupAppbar()
        setupLayout()
        setupOverlay()
        preloadAllImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    deinit {
        print("GCDViewController dihapus")
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

    // MARK: - Setup Overlay

    private func setupOverlay() {
        let stack = UIStackView(arrangedSubviews: [progressLabel, progressView])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(overlayView)
        overlayView.addSubview(cardView)
        cardView.addSubview(stack)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 260),

            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Preload

    private func preloadAllImages() {
        let group = DispatchGroup()

        for url in urls {
            group.enter()

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    GCDImageCache.shared.save(image, for: url)
                }

                DispatchQueue.main.async {
                    self?.updateProgress()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.hideOverlay()
            self?.tableView.reloadData()
        }
    }

    private func updateProgress() {
        finishedCount += 1
        let total = urls.count
        let percent = Int(Double(finishedCount) / Double(total) * 100)

        progressLabel.text = "Mengunduh \(finishedCount)/\(total) (\(percent)%)"
        progressView.setProgress(Float(finishedCount) / Float(total), animated: true)
    }

    private func hideOverlay() {
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 0
        } completion: { _ in
            self.overlayView.removeFromSuperview()
        }
    }
}

// MARK: - UITableViewDataSource

extension GCDViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        urls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: GCDCell.reuseIdentifier,
            for: indexPath
        ) as? GCDCell else {
            return UITableViewCell()
        }
        cell.configure(with: "Poster-\(indexPath.row + 1)", imageURL: urls[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension GCDViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("indexPath: \(indexPath.row)")
    }
}
