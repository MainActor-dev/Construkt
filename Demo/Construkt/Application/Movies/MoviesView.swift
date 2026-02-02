import UIKit

struct MoviesTableView: ViewBuilder {
    let movies: [Movie]
    let onSelect: (Movie) -> Void
    
    var body: View {
        TableView(DynamicItemViewBuilder(movies) { movie in
            TableViewCell {
                MovieCell(movie: movie)
            }
            .accessoryType(.disclosureIndicator)
            .onSelect { context in
                onSelect(movie)
                return false
            }
        })
        .separatorStyle(.singleLine)
        .enableSmartUpdate(Movie.self)
    }
}

struct MovieCell: ViewBuilder {
    let movie: Movie
    
    var body: View {
        HStackView {
            ImageView(nil)
                .contentMode(.scaleAspectFill)
                .cornerRadius(4)
                .clipsToBounds(true)
                .width(44)
                .height(66)
                .backgroundColor(.secondarySystemBackground)
                .with { view in
                    guard let url = movie.posterURL else { return }
                    view.setImage(from: url)
                }
            
            VStackView(spacing: 4) {
                LabelView(movie.title)
                    .font(.preferredFont(forTextStyle: .headline))
                    .numberOfLines(2)
                
                LabelView(movie.releaseDate ?? "Unknown Date")
                    .font(.preferredFont(forTextStyle: .caption1))
                    .color(.secondaryLabel)
            }
        }
        .padding(12)
        .spacing(12)
    }
}
