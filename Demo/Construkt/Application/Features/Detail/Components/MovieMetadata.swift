import UIKit
import RxSwift
import RxCocoa

struct MovieMetadata: ViewBuilder {
    
    let details: Observable<MovieDetail>
    
    var body: View {
        ZStackView {
            HStackView(spacing: 6) {
                ZStackView {
                    LabelView(details.compactMap { $0.releaseDate?.prefix(4).description })
                        .font(UIFont.systemFont(ofSize: 14))
                        .color(.lightGray)
                }
                LabelView("•")
                    .color(.darkGray)
                    .font(.systemFont(ofSize: 10))
                    .alignment(.center)
                ZStackView {
                    LabelView(details.map { $0.genreText })
                    .font(UIFont.systemFont(ofSize: 14))
                    .color(.lightGray)
                }
                LabelView("•")
                    .color(.darkGray)
                    .font(.systemFont(ofSize: 10))
                    .alignment(.center)
                ZStackView {
                    LabelView(details.map { $0.durationText })
                    .font(UIFont.systemFont(ofSize: 14))
                    .color(.lightGray)
                }
                LabelView("•")
                    .color(.darkGray)
                    .font(.systemFont(ofSize: 10))
                    .alignment(.center)
                ZStackView {
                    LabelView("4K")
                    .font(UIFont.systemFont(ofSize: 10))
                    .color(.lightGray)
                    .padding(top: 2, left: 4, bottom: 2, right: 4)
                }
                .border(color: .lightGray, lineWidth: 1)
                .cornerRadius(4)
            }
        }
    }
}
