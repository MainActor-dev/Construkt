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

struct DeliveryTrackingView: ViewBuilder {
    var body: View {
        ZStackView {
            VStackView {
                // Main container with max width and centered
                VStackView {
                    // First Section - New Tracking Number
                    VStackView {
                        // Header with tracking number
                        HStackView {
                            LabelView("No. Resi (Baru)")
                                .font(.systemFont(ofSize: 12))
                                .color(.secondaryLabel)
                            
                            HStackView {
                                LabelView("88LP98754725363")
                                    .font(.systemFont(ofSize: 14, weight: .medium))
                                    .color(.label)
                                
                                ImageView(UIImage(systemName: "doc.on.doc")!)
                                    .tintColor(.systemRed)
                                    .size(width: 20, height: 20)
                            }
                            .alignment(.center)
                        }
                        .padding(top: 4, left: 12, bottom: 4, right: 12)
                        .backgroundColor(.systemGray5)
                        .cornerRadius(8)
                        .margins(bottom: 12)
                        
                        // Recipient information
                        HStackView {
                            ZStackView {
                                CircleView()
                                    .backgroundColor(.systemOrange.withAlphaComponent(0.1))
                                    .size(width: 40, height: 40)
                                
                                ImageView(UIImage(systemName: "location")!)
                                    .tintColor(.systemOrange)
                                    .size(width: 20, height: 20)
                                    .position(.center)
                            }
                            .margins(right: 12)
                            
                            VStackView {
                                LabelView("Alamat penerima")
                                    .font(.systemFont(ofSize: 14, weight: .medium))
                                    .color(.secondaryLabel)
                                    .margins(bottom: 4)
                                
                                LabelView("Dewi Lestari • +6285678903790")
                                    .font(.systemFont(ofSize: 14, weight: .medium))
                                    .color(.label)
                                    .margins(bottom: 4)
                                
                                LabelView("Kebon Jeruk, Jakarta Barat (CGK)")
                                    .font(.systemFont(ofSize: 12))
                                    .color(.secondaryLabel)
                            }
                        }
                    }
                    .padding(16)
                    .backgroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black, radius: 1, opacity: 0.1, offset: .zero)
                    
                    // Second Section - Old Tracking Number
                    VStackView {
                        // Header with tracking number
                        HStackView {
                            LabelView("No. Resi (Lama)")
                                .font(.systemFont(ofSize: 12))
                                .color(.secondaryLabel)
                            
                            HStackView {
                                LabelView("88LP98754725363")
                                    .font(.systemFont(ofSize: 14, weight: .medium))
                                    .color(.label)
                                
                                ImageView(UIImage(systemName: "doc.on.doc")!)
                                    .tintColor(.systemRed)
                                    .size(width: 20, height: 20)
                            }
                            .alignment(.center)
                        }
                        .padding(top: 4, left: 12, bottom: 4, right: 12)
                        .backgroundColor(.systemGray5)
                        .cornerRadius(8)
                        .margins(bottom: 12)
                        
                        // Recipient information
                        HStackView {
                            ZStackView {
                                CircleView()
                                    .backgroundColor(.systemOrange.withAlphaComponent(0.1))
                                    .size(width: 40, height: 40)
                                
                                ImageView(UIImage(systemName: "location")!)
                                    .tintColor(.systemOrange)
                                    .size(width: 20, height: 20)
                                    .position(.center)
                            }
                            .margins(right: 12)
                            
                            VStackView {
                                LabelView("Alamat penerima")
                                    .font(.systemFont(ofSize: 14, weight: .medium))
                                    .color(.secondaryLabel)
                                    .margins(bottom: 4)
                                
                                LabelView("Dewi Lestari • +6285678903790")
                                    .font(.systemFont(ofSize: 14, weight: .medium))
                                    .color(.label)
                                    .margins(bottom: 4)
                                
                                LabelView("Kebon Jeruk, Jakarta Barat (CGK)")
                                    .font(.systemFont(ofSize: 12))
                                    .color(.secondaryLabel)
                            }
                        }
                    }
                    .padding(16)
                    .backgroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black, radius: 1, opacity: 0.1, offset: .zero)
                }
                .frame(width: 375)
                .spacing(16)
            }
            .backgroundColor(.systemGray6)
            .padding(16)
        }
    }
}

#Preview {
    DeliveryTrackingView().build()
}
