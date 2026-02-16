import UIKit
import RxSwift
import RxCocoa

struct MovieStoryline: ViewBuilder {
    
    let details: Observable<MovieDetail>
    
    var body: View {
        VStackView(spacing: 12) {
            LabelView("Storyline")
                .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                .color(.white)
            
            LabelView(details.map { $0.overview })
                .font(UIFont.systemFont(ofSize: 14))
                .color(.lightGray)
                .numberOfLines(0)
        }
    }
}
