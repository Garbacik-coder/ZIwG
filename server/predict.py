from neo4j import GraphDatabase
import pandas as pd
from tensorflow import keras

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

def get_users(tx):
    return list(tx.run(f'MATCH (user:User) RETURN user'))

def get_movies(tx):
    return list(tx.run(f'MATCH (movie:Movie) RETURN movie'))

def insert_is_predicted(tx, user_id, movie_id, prediction):
    return list(tx.run(f'MATCH (user:User) MATCH (movie:Movie) WHERE user.userId = {user_id} AND movie.movieId = {movie_id} CREATE (movie)-[is_predicted:IS_PREDICTED {{prediction: {prediction}}}]->(user)'))

with driver.session() as db:
    users = db.execute_write(get_users)
    movies = db.execute_write(get_movies)
    
    user_ids = []
    for user in users:
        user_ids.append(user['user']['userId'])

    movie_ids = []
    for movie in movies:
        movie_ids.append(movie['movie']['movieId'])

    df = pd.DataFrame(movie_ids, columns=['product'])
    
    model = keras.models.load_model('zapisany_model')

    for user_id in user_ids:
        df_copy = df.copy()

        df_copy['user'] = user_id
        df_copy['prediction'] = model.predict([df_copy['user'], df_copy['product']])

        for index, row in df_copy.iterrows():
            prediction = row['prediction']
            movie_id = row['product']
            result = db.execute_write(insert_is_predicted, user_id, movie_id, prediction)

        print(user_id)



