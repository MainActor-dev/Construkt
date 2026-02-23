import UIKit
import RxSwift
import RxCocoa

struct MovieSimilar: ViewBuilder {
    
    let details: Observable<MovieDetail>
    var onMovieSelected: ((Movie) -> Void)?
    
    var body: View {
        VStackView(spacing: 16) {
            LabelView("More Like This")
                .font(UIFont.systemFont(ofSize: 18, weight: .bold))
                .color(.white)
            
            ScrollView(
                HStackView {}
                    .onReceive(details.map { createSimilarViews(from: $0) }) { context in
                        context.view.reset(to: context.value)
                    }
                    .spacing(16)
                    .alignment(.top)
            )
            .showHorizontalIndicator(false)
            .height(180)
        }
    }
    
    private func createSimilarViews(from details: MovieDetail) -> [View] {
        guard let similarMovies = details.similar?.results.prefix(9) else { return [] }
        return similarMovies.map { createMoviePoster($0) }
    }
    
    private func createMoviePoster(_ movie: Movie) -> View {
        ImageView(url: movie.posterURL)
            .backgroundColor(.darkGray)
            .cornerRadius(8)
            .contentMode(.scaleAspectFill)
            .clipsToBounds(true)
            .width(120)
            .height(180)
            .onTapGesture { _ in
                onMovieSelected?(movie)
            }
    }
}
