import UIKit
import ConstruktKit

struct GenresCell: ViewBuilder {
    let id: Int
    let genre: Genre
    var isSelected: Bool = false
    
    var body: View {
        ZStackView {
            HStackView(spacing: 8) {
                LabelView(genre.name)
                    .font(.systemFont(ofSize: 14, weight: .medium))
                    .color(isSelected ? .black : .white)
                    .alignment(.center)
                    .padding(insets: .init(top: 8, left: 16, bottom: 8, right: 16))
            }
        }
        .backgroundColor(UIColor(white: 1.0, alpha: isSelected ? 1.0 : 0.1))
        .cornerRadius(20)
        .border(color: UIColor(white: 1.0, alpha: 0.2), lineWidth: 1)
        .skeletonable(true)
    }
}

import UIKit
import Construkt

// Reusable tracking section component
struct TrackingSection: ViewBuilder {
    let title: String
    let trackingNumber: String
    
    var body: View {
        VStackView {
            // Header with tracking number
            HStackView {
                LabelView(title)
                    .font(.systemFont(ofSize: 12))
                    .color(.systemGray)
                
                SpacerView()
                
                HStackView {
                    LabelView(trackingNumber)
                        .font(.monospacedDigitSystemFont(ofSize: 14, weight: .medium))
                        .color(.label)
                    
                    ImageView(UIImage(systemName: "pencil") ?? UIImage())
                        .tintColor(.red)
                        .size(width: 14, height: 14)
                }
            }
            .padding(h: 12, v: 4)
            .backgroundColor(.systemGray6)
            .cornerRadius(8)
            .margins(bottom: 3)
            
            // Address section
            HStackView {
                ImageView(UIImage(systemName: "mappin") ?? UIImage())
                    .tintColor(.systemOrange)
                    .size(width: 16, height: 16)
                    .margins(top: 1)
                
                VStackView {
                    LabelView("Alamat penerima")
                        .font(.systemFont(ofSize: 14, weight: .medium))
                        .color(.systemGray)
                        .margins(bottom: 1)
                    
                    LabelView("Dewi Lestari • +6285678903790")
                        .font(.systemFont(ofSize: 14, weight: .medium))
                        .color(.label)
                        .margins(bottom: 1)
                    
                    LabelView("Kebon Jeruk, Jakarta Barat (CGK)")
                        .font(.systemFont(ofSize: 12))
                        .color(.systemGray)
                }
                .margins(left: 3)
            }
            .alignment(.top)
        }
        .padding(12)
        .backgroundColor(.white)
        .border(color: .systemGray3, lineWidth: 1)
        .cornerRadius(12)
    }
}

// Main tracking information view
struct TrackingInfoView: ViewBuilder {
    var body: View {
        ZStackView {
            VStackView {
                TrackingSection(
                    title: "No. Resi (Baru)",
                    trackingNumber: "88LP98754725363"
                )
                
                TrackingSection(
                    title: "No. Resi (Lama)",
                    trackingNumber: "88LP98754725363"
                )
            }
            .padding(16)
            .backgroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .black, radius: 4, opacity: 0.1, offset: .zero)
        }
        .position(.center)
    }
}

#Preview {
    TrackingInfoView().build()
}
