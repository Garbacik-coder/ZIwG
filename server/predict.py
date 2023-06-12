from neo4j import GraphDatabase
import pandas as pd
from tensorflow import keras

pd.set_option('display.max_columns', 500)

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

genres = ['War', 'Children', 'Thriller', 'Crime', 'Drama', 'Animation', 'Horror', 'Fantasy', 'IMAX', 'Sci-Fi', 'Western', 'Comedy', 'Action', 'Romance', 'Adventure', 'Musical', 'Documentary', 'Film-Noir', 'Mystery']

def get_users(tx):
    return list(tx.run(f'MATCH (user:User) RETURN user'))

def get_movies(tx):
    return list(tx.run(f'MATCH (movie:Movie) MATCH (movie)-[is_genre:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) as genres'))

def insert_is_predicted(tx, user_id, movie_id, prediction):
    return list(tx.run(f"MATCH (user:User) MATCH (movie:Movie) WHERE user.id = {user_id} AND movie.movieId = {movie_id} AND NOT (user)-[:RATED]->(movie) CREATE (movie)-[is_predicted:IS_PREDICTED {{prediction: {prediction}}}]->(user)"))

with driver.session() as db:
    users = db.execute_write(get_users)
    movies = db.execute_write(get_movies)
    
    user_ids = []
    for user in users:
        user_ids.append(int(user['user']['id']))

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

    df = pd.DataFrame(movie_ids, columns=['product'])
    df['old'] = movie_old
    for genre in genres:
        df[genre] = movie_genres[genre]

    model = keras.models.load_model('zapisany_model3')

    features = ['old']
    features.extend(genres)

    for user_id in user_ids:
        df_copy = df.copy()

        df_copy['user'] = user_id

        df_copy['prediction'] = model.predict([df_copy['user'], df_copy['product'], df_copy[features]])

        for index, row in df_copy.iterrows():
            prediction = row['prediction']
            movie_id = row['product']
            result = db.execute_write(insert_is_predicted, user_id, movie_id, prediction)

        print(user_id)



