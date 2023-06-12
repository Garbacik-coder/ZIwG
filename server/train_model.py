import pandas as pd
import numpy as np
from neo4j import GraphDatabase
from model import create_model

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

genres = ['War', 'Children', 'Thriller', 'Crime', 'Drama', 'Animation', 'Horror', 'Fantasy', 'IMAX', 'Sci-Fi', 'Western', 'Comedy', 'Action', 'Romance', 'Adventure', 'Musical', 'Documentary', 'Film-Noir', 'Mystery']

def get_users(tx):
    return list(tx.run(f'MATCH (user:User) RETURN user ORDER BY user.id'))

def get_ratings(tx):
    return list(tx.run(f'MATCH (user:User)-[rated:RATED]->(movie:Movie) RETURN user, rated, movie ORDER BY user.id'))

def get_movies(tx):
    return list(tx.run(f'MATCH (movie:Movie) MATCH (movie)-[is_genre:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) as genres ORDER BY movie.movieId'))

with driver.session() as db:
    users = db.execute_read(get_users)
    movies = db.execute_read(get_movies)
    ratings = db.execute_read(get_ratings)
  
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

    dtf_products['product'] = dtf_products['product'].astype(int)
    dtf_products = dtf_products.set_index('product')

    user_ids = []
    for user in users:
        user_ids.append(user['user']['id'])

    dtf_users = pd.DataFrame(user_ids, columns=['user'])

    for movie_id in movie_ids:
        df = pd.DataFrame(np.nan, index=user_ids, columns=[movie_id])
        dtf_users = pd.concat((dtf_users, df), axis=1)

    for rating in ratings:
        movie_id = rating['movie']['movieId']
        user_id = rating['user']['id']
        value = rating['rated']['rating']
        dtf_users[movie_id]
        dtf_users.loc[dtf_users['user'] == user_id, movie_id] = value

    dtf_users['user'] = dtf_users['user'].astype(int)
    dtf_users = dtf_users.set_index('user')

    create_model(dtf_users, dtf_products)