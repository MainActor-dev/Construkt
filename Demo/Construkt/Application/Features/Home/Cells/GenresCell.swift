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

struct PaymentSuccessView: ViewBuilder {
    var body: View {
        VerticalScrollView(safeArea: true) {
            ZStackView {
                
                VStackView(spacing: 8) {
                    // Success icon
                    ZStackView {
                        Modified(UIView())
                            .size(width: 128, height: 128)
                            .backgroundColor(.systemGreen)
                            .cornerRadius(64)
                        
                        // Checkmark icon (using a simple label with checkmark)
                        LabelView("✓")
                            .font(.systemFont(ofSize: 48, weight: .bold))
                            .color(.white)
                            .position(.center)
                    }
                    
                    // Title
                    LabelView("Pembayaran berhasil!!")
                        .font(.title2)
                        .color(.label)
                        .alignment(.center)
                        .padding(h: 20, v: 0)
                    
                    // Subtitle
                    LabelView("Terima kasih, pembayaranmu sudah kami terima.")
                        .font(.body)
                        .color(.secondaryLabel)
                        .alignment(.center)
                        .padding(h: 20, v: 0)
                        .margins(h: 0, v: 20)
                    
                    // Buttons container
                    VStackView(spacing: 16) {
                        ButtonView("Lacak")
                            .font(.headline)
                            .color(.white)
                            .backgroundColor(.systemRed)
                            .padding(16)
                            .cornerRadius(24)
                            .contentHorizontalAlignment(.center)
                            .width(200)
                        
                        ButtonView("Lihat bukti pembayaran")
                            .font(.headline)
                            .color(.systemRed)
                            .border(color: .systemRed, lineWidth: 2)
                            .padding(16)
                            .cornerRadius(24)
                            .contentHorizontalAlignment(.center)
                            .width(200)
                    }
                    .margins(h: 0, v: 40)
                }
                .padding(h: 40, v: 0)
                .alignment(.center)
            }
        }
    }
}

#Preview {
    PaymentSuccessView().build()
}
