import UIKit

struct MovieListNavBar: ViewBuilder {
    
    let title: String
    let onTapBack: () -> Void
    
    var body: View {
        CustomNavigationBar(
            leading: [
                HStackView {
                    ImageView(systemName: "arrow.left")
                        .tintColor(.white)
                        .size(width: 24, height: 24)
                        .contentMode(.scaleAspectFit)
                }.onTapGesture { _ in onTapBack() }
            ],
            customTitle: LabelView(title)
                .font(.systemFont(ofSize: 18, weight: .semibold))
                .color(.white),
            trailing: [
                ImageView(systemName: "arrow.up.arrow.down")
                    .tintColor(.gray)
                    .size(width: 20, height: 20)
                    .contentMode(.scaleAspectFit)
            ]
        )
        .position(.top)
        .height(48)
        .backgroundColor(UIColor("#0A0A0A"))
    }
}
