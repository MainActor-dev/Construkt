import UIKit
import ConstruktKit

// Colors to be shared
private let orangeColor = UIColor(red: 1.0, green: 0.31, blue: 0.0, alpha: 1.0)
private let lightGray = UIColor(white: 0.96, alpha: 1.0)

// MARK: - Reusable Row Components

struct FeatureRowView: ViewBuilder {
    let icon: String
    let title: String
    let desc: String
    
    var body: View {
        ZStackView {
            HStackView {
                ZStackView {
                    ImageView(UIImage(systemName: icon) ?? UIImage())
                        .tintColor(UIColor(red: 0.9, green: 0.36, blue: 0.0, alpha: 1.0))
                        .size(width: 36, height: 36)
                        .position(.center)
                        .contentMode(.scaleAspectFit)
                        .clipsToBounds(true)
                }
                .width(40, priority: .required)
                .height(40, priority: .required)
                .backgroundColor(UIColor("#FFF7F2"))
                .cornerRadius(20)
                .shadow(color: .black, radius: 4, opacity: 0.05, offset: .zero)
                
                VStackView {
                    LabelView(title)
                        .font(.systemFont(ofSize: 14, weight: .bold))
                        .color(UIColor(red: 0.84, green: 0.36, blue: 0.05, alpha: 1.0))
                    LabelView(desc)
                        .font(.systemFont(ofSize: 12, weight: .regular))
                        .color(.darkGray)
                        .numberOfLines(0)
                }
                .spacing(2)
            }
            .alignment(.center)
            .padding(8)
        }
        .height(70)
        .cornerRadius(14)
    }
}

struct TableRowView: ViewBuilder {
    let col1: String
    let col2: String
    
    var body: View {
        HStackView {
            LabelView(col1)
                .font(.systemFont(ofSize: 12, weight: .medium))
                .color(UIColor("#1E1E1E"))
                .alignment(.center)
                .numberOfLines(0)
            LabelView(col2)
                .font(.systemFont(ofSize: 12, weight: .medium))
                .color(UIColor("#1E1E1E"))
                .alignment(.center)
                .numberOfLines(0)
        }
        .distribution(.fillEqually)
        .padding(h: 12, v: 8)
    }
}

// MARK: - Section Components

struct TopCardView: ViewBuilder {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: View {
        ZStackView {
             InnerShadow(color: UIColor(red: 1.0, green: 0.74, blue: 0.55, alpha: 1.0), radius: 8, x: 0, y: 8)
            .cornerRadius(20)
            VStackView {
                ImageView(UIImage(systemName: icon) ?? UIImage())
                    .tintColor(orangeColor)
                    .size(width: 30, height: 30)
                LabelView(title)
                    .font(.systemFont(ofSize: 13, weight: .bold))
                    .padding(top: 8)
                LabelView(subtitle)
                    .font(.systemFont(ofSize: 11, weight: .bold))
                    .color(orangeColor)
            }
            .alignment(.center)
            .padding(16)
        }
        .backgroundColor(.white)
        .cornerRadius(20)
        .height(110)
    }
}

struct HeaderSectionView: ViewBuilder {
    var body: View {
        ZStackView {
            VStackView {
                HStackView {
                    LabelView("Dompet digital yang beneran ngerti kebutuhan bayar-bayar ongkirmu di aplikasi & agen.")
                        .color(.white)
                        .font(.systemFont(ofSize: 14, weight: .medium))
                        .numberOfLines(0)
                        
                    ImageView(UIImage(systemName: "creditcard.fill") ?? UIImage())
                        .tintColor(.systemYellow)
                        .width(95, priority: .required)
                        .height(88, priority: .required)
                        .contentMode(.scaleAspectFit)
                }
                .distribution(.equalCentering)
                
                HStackView {
                    TopCardView(icon: "wallet.pass", title: "Isi LioPay", subtitle: "hemat s.d 30%")
                    TopCardView(icon: "bolt.fill", title: "Bayar cepat", subtitle: "pakai LioPay")
                }
                .spacing(12)
                .distribution(.fillEqually)
                .position(.bottom)
                .margins(h: 20, v: 0)
            }
            .backgroundColor(orangeColor)
            .padding(h: 16, v: 12)
        }
    }
}

struct KeuntunganSectionView: ViewBuilder {
    var body: View {
        ZStackView {
            VStackView {
                GradientLabelView("Keuntungan pakai LioPay", colors: [UIColor(red: 0.8, green: 0.3, blue: 0.0, alpha: 1.0), UIColor(red: 0.9, green: 0.5, blue: 0.0, alpha: 1.0)])
                    .font(.systemFont(ofSize: 16, weight: .bold))
                    .alignment(.center)
                VStackView(spacing: 8) {
                    FeatureRowView(icon: "ticket.fill", title: "Diskon voucher hingga 30%", desc: "Dapatkan diskon vouchertiap isi saldo.")
                    FeatureRowView(icon: "building.2.fill", title: "Bayar pakai LioPay di agen", desc: "Mau bayar di aplikasi/agen, semua bisa pakai LioPay.")
                    FeatureRowView(icon: "arrow.uturn.left.circle.fill", title: "Refund Instan", desc: "Dana masuk ke LioPay jika pengiriman gagal.")
                    FeatureRowView(icon: "shippingbox.fill", title: "Bayar ongkir lebih cepat", desc: "Tidak perlu pindah aplikasi, pakai LioPay aja!")
                }
            }
            .padding(8)
            .margins(h: 16, v: 8)
            .backgroundColor(.white)
            .cornerRadius(12)
        }
        .backgroundColor(.clear)
    }
}

struct PerbedaanSectionView: ViewBuilder {
    var body: View {
        ZStackView {
            VStackView(spacing: 12) {
                LabelView("Perbedaan LioPay & Parcel Poin")
                    .font(.systemFont(ofSize: 16, weight: .bold))
                    .alignment(.center)
                VStackView {
                    ZStackView {
                        HStackView {
                            LabelView("LioPay")
                                .font(.systemFont(ofSize: 13, weight: .bold))
                                .color(UIColor(red: 0.84, green: 0.36, blue: 0.05, alpha: 1.0))
                                .alignment(.center)
                                
                            LabelView("Parcel Poin")
                                .font(.systemFont(ofSize: 13, weight: .bold))
                                .color(UIColor(red: 0.84, green: 0.36, blue: 0.05, alpha: 1.0))
                                .alignment(.center)
                        }
                        .distribution(.fillEqually)
                        .padding(h: 0, v: 12)
                        
                         VerticalDividerView(verticalInset: 4.5)
                                .color(UIColor("#EEEEEE"))
                    }
                    .backgroundColor(UIColor(red: 1.0, green: 0.95, blue: 0.93, alpha: 1.0))
                    .cornerRadius(20)
                    .margins(top: 12, left: 12, bottom: 0, right: 12)
                    
                    TableRowView(col1: "Didapat dari pembelian voucher & penghasilan COD", col2: "Didapat dari cashback pengiriman")
                    DividerView().color(UIColor("EAECF0"))
                    TableRowView(col1: "Digunakan untuk\n bayar ongkir", col2: "Digunakan untuk bayar ongkir & tukar voucher")
                    DividerView().color(UIColor("EAECF0"))
                    TableRowView(col1: "Bisa dicairkan", col2: "Tidak bisa dicairkan")
                    DividerView().color(UIColor("EAECF0"))
                    TableRowView(col1: "Berlaku selamanya", col2: "Ada masa berlaku")
                }
                .padding(h: 8, v: 0)
            }
            .padding(top: 12, bottom: 12)
            .margins(h: 16, v: 8)
            .backgroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct StickyButtonView: ViewBuilder {
    var body: View {
        VStackView {
            ButtonView("Isi LioPay sekarang")
                .font(.systemFont(ofSize: 15, weight: .bold))
                .color(.white, for: .normal)
                .backgroundColor(.red, for: .normal)
                .cornerRadius(12)
                .height(50)
        }
        .padding(top: 16, left: 20, bottom: 32, right: 20)
        .backgroundColor(.white)
        .position(.bottom)
    }
}

// MARK: - Main View Controller

class DemoViewController: UIViewController {
    override func loadView() {
        let viewBuilder = ZStackView {
            VerticalScrollView(safeArea: false) {
                VStackView {
                    HeaderSectionView()
                    KeuntunganSectionView()
                    PerbedaanSectionView()
                    
                    LabelView("Butuh bantuan?")
                        .font(.systemFont(ofSize: 13, weight: .bold))
                        .color(.red)
                        .alignment(.center)
                        .padding(top: 32, bottom: 120) // extra padding for bottom button
                }
            }
            
            StickyButtonView()
        }
        .backgroundColor(UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0))
        
        self.view = viewBuilder.build()
    }
}
