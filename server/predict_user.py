import pandas as pd
from tensorflow import keras

genres = ['War', 'Children', 'Thriller', 'Crime', 'Drama', 'Animation', 'Horror', 'Fantasy', 'IMAX', 'Sci-Fi', 'Western', 'Comedy', 'Action', 'Romance', 'Adventure', 'Musical', 'Documentary', 'Film-Noir', 'Mystery']

def get_movies(tx):
    return list(tx.run(f'MATCH (movie:Movie) MATCH (movie)-[is_genre:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) as genres ORDER BY movie.movieId'))

def insert_is_predicted(tx, user_id, movie_id, prediction):
    return list(tx.run(f"MATCH (user:User) MATCH (movie:Movie) WHERE user.id = {user_id} AND movie.movieId = {movie_id} AND NOT (user)-[:RATED]->(movie) CREATE (movie)-[is_predicted:IS_PREDICTED {{prediction: {prediction}}}]->(user)"))


def predict(db, user_id):
    model = keras.models.load_model('zapisany_model3')

    movies = db.execute_read(get_movies)

    movie_ids = []
    movie_old = []
    movie_genres = {}

    for genre in genres:
        movie_genres[genre] = []

    for movie in movies:
        movie_ids.append(movie['movie']['movieId'])
        movie_old.append(movie['movie']['old'])
        for genre in genres:
            if genre in movie['genres']:
                movie_genres[genre].append(1)
            else:
                movie_genres[genre].append(0)

    dtf_products = pd.DataFrame(movie_ids, columns=['product'])
    dtf_products['old'] = movie_old
    for genre in genres:
        dtf_products[genre] = movie_genres[genre]

    features = ['old']
    features.extend(genres)

    dtf_products['user'] = user_id
    dtf_products['yhat'] = model.predict([dtf_products['user'], dtf_products['product'], dtf_products[features]])

    for index, row in dtf_products.iterrows():
        result = db.execute_write(insert_is_predicted, user_id, row['product'], row['yhat'])

