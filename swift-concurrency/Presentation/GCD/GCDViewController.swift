//
//  GCDViewController.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 23/10/26.
//

import UIKit

class GCDViewController: UIViewController {

    // MARK: - Properties
    
    private let urls: [URL] = (1...100).compactMap {
        URL(string: "https://picsum.photos/id/\($0)/300/450")
    }
    
    private var totalFinished = 0

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
    
    //MARK: Overlay atau Layar gelap belakang
    
    private let overlayView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: CardView
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Text Jumlah download
    
    private let progressLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Mengunduh 0/100 (0%)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    } ()
    
    //MARK: Progress download

    private let progressView: UIProgressView = {
        let label = UIProgressView()
        label.progress = 0
        label.tintColor = .systemIndigo
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Stack gabung text jumlah download dan progress download
    
    private lazy var stackProgress: UIStackView = {
        let view = UIStackView(arrangedSubviews: [progressLabel, progressView])
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupAppbar()
        setupLayout()
        preload()
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
        view.addSubview(overlayView)
        overlayView.addSubview(cardView)
        cardView.addSubview(stackProgress)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 260),
            
            stackProgress.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            stackProgress.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            stackProgress.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            stackProgress.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
        ])
    }
    
    // MARK: - Preload
    
    private func preload() {
        
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
            self?.tableView.reloadData()
            self?.hideOverlay()
        }
        
    }

    // MARK: - Update Progress
    
    private func updateProgress() {
        totalFinished += 1
        let total = urls.count
        let percent = Int(Double(totalFinished) / Double(total) * 100)

        progressLabel.text = "Mengunduh \(totalFinished)/\(total) (\(percent)%)"
        progressView.setProgress(Float(totalFinished) / Float(total), animated: true)
    }

    // MARK: - Hide Overlay

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
