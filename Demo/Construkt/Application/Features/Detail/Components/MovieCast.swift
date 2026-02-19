import UIKit
import RxSwift
import RxCocoa

struct MovieCast: ViewBuilder {
    
    let casts: Observable<[Cast]>
    var onCastSelected: ((Cast) -> Void)?
    
    var body: View {
        VStackView(spacing: 16) {
            HStackView {
                LabelView("Cast & Crew")
                    .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                    .color(.white)
                SpacerView()
                LabelView("View all")
                    .font(UIFont.systemFont(ofSize: 14))
                    .color(.gray)
            }
            
            ScrollView(
                HStackView {}
                    .onReceive(casts.map { createCastViews(from: $0) }) { context in
                        context.view.reset(to: context.value)
                    }
                    .spacing(16)
                    .spacing(16)
                    .alignment(.fill)
            )
            .showHorizontalIndicator(false)
            .bounces(false)
            .with {
                $0.heightAnchor.constraint(equalTo: $0.contentLayoutGuide.heightAnchor).isActive = true
            }
        }
        .onReceive(casts.map { $0.isEmpty }) { context in
            context.view.isHidden = context.value
        }
    }
    
    private func createCastViews(from casts: [Cast]) -> [View] {
        guard !casts.isEmpty else { return [] }
        return casts.prefix(10).map { createCastView($0) }
    }
    
    private func createCastView(_ cast: Cast) -> View {
        VStackView {
            ImageView(url: cast.profileURL)
                .backgroundColor(.darkGray)
                .cornerRadius(30)
                .width(60)
                .height(60)
                .clipsToBounds(true)
                .contentMode(.scaleAspectFill)
            
            ZStackView {
                VStackView(spacing: 4) {
                    LabelView(cast.name)
                        .font(UIFont.systemFont(ofSize: 12, weight: .medium))
                        .color(.white)
                        .numberOfLines(2)
                        .alignment(.center)
                    
                    LabelView(cast.character)
                        .font(UIFont.systemFont(ofSize: 10))
                        .color(.gray)
                        .numberOfLines(1)
                        .alignment(.center)
                }
                .alignment(.center)
            }
        }
        .width(max: 100, priority: .required)
        .alignment(.center)
        .padding(h: 2, v: 4)
        .onTapGesture { _ in
            onCastSelected?(cast)
        }
    }
}
