//
//  AsyncCell.swift
//  swift-concurrency
//
//  Created by Vokal-Ican on 23/10/26.
//

import UIKit

class AsyncCell: UITableViewCell {
    
    // MARK: - Identifier

    static let reuseIdentifier = "AsyncCell"

    // MARK: - Properties
    
    private var loadTask: Task<Void,Never>?

    private var currentURL: URL?
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup Views appear
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(rowStackView)
        setupLayout()
    }
    
    //MARK: - Setup Auto Layout
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            rowStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            rowStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            rowStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rowStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - UI
    
    private let posterImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var rowStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [posterImageView, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Configure

    func configure(with title: String, imageURL: URL) {
        titleLabel.text = title
        currentURL = imageURL

        if let cached = AsyncImageLoader.shared.image(for: imageURL) {
            posterImageView.image = cached
            return
        }

        posterImageView.image = UIImage(systemName: "photo")

        loadTask = Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: imageURL),
                  let image = UIImage(data: data),
                  !Task.isCancelled else { return }

            AsyncImageLoader.shared.save(image, for: imageURL)

            guard self?.currentURL == imageURL else { return }
            self?.posterImageView.image = image
        }
    }

    // MARK: - Prepare For Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        loadTask?.cancel()
        loadTask = nil
        posterImageView.image = nil
        titleLabel.text = nil
        currentURL = nil
    }
    
}
