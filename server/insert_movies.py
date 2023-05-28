import pandas as pd
from neo4j import GraphDatabase

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

df = pd.read_csv('products.csv')
df['name'] = df['name'].astype(str).apply(lambda x: x.replace('"', ''))

def insert_movie(tx, movie_id, title, old):
    return list(tx.run(f'CREATE (movie:Movie) SET movie.movieId = {movie_id}, movie.title = "{title}", movie.old = {old}'))

def insert_genre(tx, name):
    return list(tx.run(f'CREATE (genre:Genre) SET genre.name = "{name}"'))

def connect_with_genre(tx, movie_id, genre_name):
    return list(tx.run(f'MATCH (movie:Movie) MATCH (genre:Genre) WHERE movie.movieId = {movie_id} AND genre.name = "{genre_name}" CREATE (movie)-[is_genre:IS_GENRE]->(genre)'))

genres = ['Mystery', 'Film-Noir', 'Drama', 'Documentary', 'Sci-Fi', 'Action', 'Adventure', 'War', 'IMAX', 'Fantasy', 'Children', 'Romance', 'Horror', 'Thriller', 'Animation', 'Comedy', 'Musical', 'Crime', 'Western']

with driver.session() as db:
    for genre in genres:
        result = db.execute_write(insert_genre, genre)
    
    for index, row in df.iterrows():
        movie_id = row['product']  
        title = row['name']
        old = row['old']
        result = db.execute_write(insert_movie, movie_id, title, old)
        for genre in genres:
            if row[genre] == 1:
                result = db.execute_write(connect_with_genre, movie_id, genre)
        print(movie_id)
