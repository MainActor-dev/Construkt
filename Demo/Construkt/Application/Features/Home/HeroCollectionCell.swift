import UIKit
import SnapKit

// MARK: - Hero Collection Cell
final class HeroCollectionCell: UICollectionViewCell {
    
    let heroContentView = HeroContentView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(heroContentView)
        heroContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with movie: Movie) {
        heroContentView.configure(with: movie)
    }
}
