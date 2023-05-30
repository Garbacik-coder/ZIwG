from flask import Flask, g, request
from flask_restful import Resource, Api
from neo4j import GraphDatabase
import pandas as pd

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

SERVER_HOST = '0.0.0.0'
SERVER_PORT = 8080

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

app = Flask(__name__)
api = Api(app)

def get_db():
    g.user = {'userId': 0}
    if not hasattr(g, 'neo4j_db'):
        g.neo4j_db = driver.session()
    return g.neo4j_db

def close_db(error):
    if hasattr(g, 'neo4j_db'):
        g.neo4j_db.close()

def serialize_movie(movie, genres, on_watchlist, rated):
    rating = None
    if rated is not None:
        rating = rated['rating']
    
    return {
        'movieId': movie['movieId'],
        'title': movie['title'],
        'description': 'z IMDb trzeba to wziac',
        'genres': genres,
        'year': movie['year'],
        'length': 'z IMDb',
        'imageUrl': 'jak wyzej',
        'isOnWatchlist': on_watchlist,
        'isRated': rating is not None,
        'rating': rating
    }

def envelop_movies(movies):
    return {
        'movies': movies,
        'count': len(movies)
    }

def try_parse_int(value, default_value):
    try:
        return int(value)
    except ValueError:
        return default_value

def check_offset_and_limit(result, offset, limit):
    if (offset < 0):
        offset = 0

    if (offset > len(result)):
        offset = len(result)

    if (limit < 0):
        limit = 0

    if (offset + limit > len(result)):
        limit = len(result) - offset

    return offset, limit

class Movies(Resource):
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)

        def get_movies(tx, user_id):
            return list(tx.run(f'MATCH (movie:Movie) OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) OPTIONAL MATCH (:User {{userId: {user_id}}})-[rated:RATED]->(movie) RETURN movie, COLLECT(genre.name) as genres, EXISTS((movie)-[:ON_WATCHLIST]->(:User {{userId: {user_id}}})) as on_watchlist, rated'))

        db = get_db()
        result = db.execute_write(get_movies, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], result[i]['on_watchlist'], result[i]['rated']) for i in range(offset, offset + limit)])

class Recommended(Resource):
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)

        def get_recommended(tx, user_id):
            return list(tx.run(f'MATCH (movie:Movie)-[is_predicted:IS_PREDICTED]->(user:User) WHERE user.userId = {user_id} WITH movie ORDER BY is_predicted.prediction DESC OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) as genres, EXISTS((movie)-[:ON_WATCHLIST]->(:User {{userId: {user_id}}})) as on_watchlist'))

        db = get_db()
        result = db.execute_write(get_recommended, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], result[i]['on_watchlist'], None) for i in range(offset, offset + limit)])

class OnWatchlist(Resource):
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)

        def get_on_watchlist(tx, user_id):
            return list(tx.run(f'MATCH (movie:Movie)-[on:ON_WATCHLIST]->(user:User) WHERE user.userId = {user_id} OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) OPTIONAL MATCH (:User {{userId: {user_id}}})-[rated:RATED]->(movie) RETURN movie, COLLECT(genre.name) as genres, rated'))

        db = get_db()
        result = db.execute_write(get_on_watchlist, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], True, result[i]['rated']) for i in range(offset, offset + limit)])

class Rated(Resource):
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)

        def get_rated(tx, user_id):
            return list(tx.run(f'MATCH (user:User)-[rated:RATED]->(movie:Movie) WHERE user.userId = {user_id} OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) as genres, EXISTS((movie)-[:ON_WATCHLIST]->(:User {{userId: {user_id}}})) as on_watchlist, rated'))

        db = get_db()
        result = db.execute_write(get_rated, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], result[i]['on_watchlist'], result[i]['rated']) for i in range(offset, offset + limit)])

class AddToWatchlist(Resource):
    def post(self, movieId):
        def add_to_watchlist(tx, movie_id, user_id):
            return tx.run(f'MATCH (movie:Movie) MATCH (user:User) WHERE movie.movieId = {movie_id} AND user.userId = {user_id} CREATE (movie)-[on_watchlist:ON_WATCHLIST]->(user)')

        db = get_db()
        result = db.execute_write(add_to_watchlist, movieId, g.user['userId'])
        return {}

class RemoveFromWatchlist(Resource):
    def post(self, movieId):
        def remove_from_watchlist(tx, movie_id, user_id):
            return tx.run(f'MATCH (movie:Movie)-[on_watchlist:ON_WATCHLIST]->(user:User) WHERE movie.movieId = {movie_id} AND user.userId = {user_id} DELETE on_watchlist')

        db = get_db()
        result = db.execute_write(remove_from_watchlist, movieId, g.user['userId'])
        return {}

class Rate(Resource):
    def post(self, movieId):
        rating = request.args.get('rating')

        def rate_movie(tx, user_id, movie_id, rating):
            return tx.run(f'MATCH (user:User) MATCH (movie:Movie) WHERE user.userId = {user_id} AND movie.movieId = {movie_id} CREATE (user)-[rated:RATED {{rating: {rating}}}]->(movie)')

        db = get_db()
        result = db.execute_write(rate_movie, g.user['userId'], movieId, rating)
        return {}

class Unrate(Resource):
    def post(self, movieId):
        def unrate_movie(tx, user_id, movie_id):
            return tx.run(f'MATCH (user:User)-[rated:RATED]-(movie:Movie) WHERE user.userId = {user_id} AND movie.movieId = {movie_id} DELETE rated')

        db = get_db()
        result = db.execute_write(unrate_movie, g.user['userId'], movieId)
        return {}

api.add_resource(Movies, '/api/movies')
api.add_resource(Recommended, '/api/movies/recommended')
api.add_resource(OnWatchlist, '/api/movies/on_watchlist')
api.add_resource(Rated, '/api/movies/rated')
api.add_resource(AddToWatchlist, '/api/movies/<int:movieId>/add_to_watchlist')
api.add_resource(RemoveFromWatchlist, '/api/movies/<int:movieId>/remove_from_watchlist')
api.add_resource(Rate, '/api/movies/<int:movieId>/rate')
api.add_resource(Unrate, '/api/movies/<int:movieId>/unrate')

app.run(host=SERVER_HOST, port=SERVER_PORT)