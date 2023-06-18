import pandas as pd
import numpy as np
from neo4j import GraphDatabase

MOVIES_NUM = 9742

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

df = pd.read_csv('users.csv')

def insert_rating(tx, user_id, movie_id, rating):
    return list(tx.run(f"MATCH (user:User) MATCH (movie:Movie) WHERE user.id = {user_id} AND movie.movieId = {movie_id} CREATE (user)-[rated:RATED {{rating: {rating}}}]->(movie)"))

with driver.session() as db:
    for index, row in df.iterrows():
        print(index)
        for i in range(0, MOVIES_NUM):
            if not np.isnan(row[str(i)]):
                user_id = row['user']
                movie_id = i
                rating = row[str(i)]
                result = db.execute_write(insert_rating, user_id, movie_id, rating)
        