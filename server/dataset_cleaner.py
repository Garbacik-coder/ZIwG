import pandas as pd
import numpy as np

pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1000)

def extract_genre_names(genres):
    genre_names = []

    for row in genres:
        for genre in row.split('|'):
            if genre not in genre_names:
                genre_names.append(genre)

    return genre_names

def read_movies():
    movies_df = pd.read_csv('movies.csv')

    genres = movies_df['genres']

    genre_names = extract_genre_names(genres)

    for genre_name in genre_names:
        movies_df[genre_name] = 0

    for index, row in movies_df.iterrows():
        for genre_name in genre_names:
            if genre_name in row['genres'].split('|'):
                movies_df.at[index, genre_name] = 1

    movies_df.drop('genres', inplace=True, axis=1)
    movies_df.drop('title', inplace=True, axis=1)

    #movies_df.to_csv('wynik.csv', index=False)
    return movies_df

def read_ratings():
    ratings_df = pd.read_csv('ratings.csv')
    ratings_df.drop('timestamp', inplace=True, axis=1)
    
    for index, row in ratings_df.iterrows():
        ratings_df.at[index, 'rating'] = 2 * ratings_df.at[index, 'rating'] - 1

    return ratings_df

def merge_datasets(movies_df, ratings_df):
    movies_df = read_movies()
    ratings_df = read_ratings()

    result_df = pd.merge(movies_df, ratings_df, on="movieId")

    return result_df

merge_datasets(read_movies(), read_ratings()).to_csv('result.csv', index=False)
