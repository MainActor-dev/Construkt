//
//  HeaderFooterViewController.swift
//  Construkt
//
//  Created by User on 2026-02-03.
//

import UIKit

class HeaderFooterViewController: UIViewController {
    
    var body: View {
        CollectionView {
            Section(id: DefaultSectionIdentifier.defaultIdentifier) {
                
                Header {
                    LabelView("Header Title")
                        .font(.systemFont(ofSize: 24, weight: .bold))
                        .padding(16)
                        .backgroundColor(.secondarySystemBackground)
                }
                
                Cell(1, id: 1) { item in
                    LabelView("Item \(item)")
                        .padding(16)
                        .backgroundColor(.white)
                        .cornerRadius(8)
                }
                Cell(2, id: 2) { item in
                    LabelView("Item \(item)")
                        .padding(16)
                        .backgroundColor(.white)
                        .cornerRadius(8)
                }
                
                Footer {
                     LabelView("Footer Note")
                        .font(.systemFont(ofSize: 14))
                        .color(.gray)
                        .padding(16)
                        .alignment(.center)
                }
                
            }
            .layout { _ in
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                section.interGroupSpacing = 10
                
                // Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                
                // Footer
                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let footer = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: footerSize,
                    elementKind: UICollectionView.elementKindSectionFooter,
                    alignment: .bottom
                )
                
                section.boundarySupplementaryItems = [header, footer]
                
                return section
            }
            
            Section(id: DefaultSectionIdentifier(uniqueId: "empty_demo")) {
                return [CellController]()
            }
            .header {
                 Header {
                    LabelView("Empty Section Demo")
                        .font(.systemFont(ofSize: 20, weight: .bold))
                        .padding(16)
                 }
            }
            .emptyState {
                VStackView {
                    ImageView(systemName: "tray")
                        .tintColor(.gray)
                        .contentMode(.scaleAspectFit)
                        
                    LabelView("No items here!")
                        .color(.gray)
                        .alignment(.center)
                }
                .spacing(8)
                .alignment(.center)
                .padding(32)
            }
        }
        .backgroundColor(.systemGroupedBackground)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Headers & Footers"
        view.backgroundColor = .systemBackground
        view.embed(body)
    }
}
