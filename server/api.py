from flask import Flask, g, request, request_started, abort
from flask_restful import Resource, Api
from neo4j import GraphDatabase
import pandas as pd
from functools import wraps
import re
from predict_user import predict
from threading import Thread

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

SERVER_HOST = '0.0.0.0'
SERVER_PORT = 8080

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

app = Flask(__name__)
api = Api(app)

def set_user(self):
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        g.user = {'userId': None}
        return

    match = re.match(r'^Bearer (\S+)', auth_header)
    token = match.group(1)

    def get_user_by_token(tx, token):
        return tx.run(f"MATCH (user:User) WHERE user.token = '{token}' RETURN user").single()

    db = get_db()
    result = db.execute_read(get_user_by_token, token)
    try:
        g.user = result['user']
    except (KeyError, TypeError):
        abort(401, 'invalid authorization key')
    return

request_started.connect(set_user, app)

def login_required(f):
    @wraps(f)
    def wrapped(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return {'message': 'no authorization provided'}, 401
        return f(*args, **kwargs)
    return wrapped

def get_db():
    if not hasattr(g, 'neo4j_db'):
        g.neo4j_db = driver.session()
    return g.neo4j_db

def close_db(error):
    if hasattr(g, 'neo4j_db'):
        g.neo4j_db.close()

def serialize_movie(movie, genres, on_watchlist, rated, overallRating):
    rating = None
    if rated is not None:
        rating = rated['rating'] * 10

    if overallRating is not None:
        overallRating = overallRating * 10

    return {
        'movieId': movie['movieId'],
        'title': movie['title'],
        'description': movie['description'],
        'genres': genres,
        'rating': overallRating,
        'year': movie['year'],
        'length': movie['length'],
        'imageUrl': movie['imageUrl'],
        'isOnWatchlist': on_watchlist,
        'isRated': rating is not None,
        'userRating': rating
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

def generate_filter_clause(substring, where):
    if substring is None:
        return ""
    elif where:
        return f"WHERE movie.title =~ '(?i).*{substring}.*' "
    else:
        return f"AND movie.title =~ '(?i).*{substring}.*' "

class Movies(Resource):
    @login_required
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)
        substring = request.args.get('substring')

        def get_movies(tx, user_id):
            filterClause = generate_filter_clause(substring, True)
            return list(tx.run(f"MATCH (movie:Movie) {filterClause}WITH movie OPTIONAL MATCH (:User)-[overallRated:RATED]->(movie) WITH movie, avg(overallRated.rating) as overallRated OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) OPTIONAL MATCH (:User {{userId: '{user_id}'}})-[rated:RATED]->(movie) RETURN movie, COLLECT(genre.name) as genres, EXISTS((movie)-[:ON_WATCHLIST]->(:User {{userId: '{user_id}'}})) as on_watchlist, rated, overallRated"))

        db = get_db()
        result = db.execute_write(get_movies, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], result[i]['on_watchlist'], result[i]['rated'], result[i]['overallRated']) for i in range(offset, offset + limit)])

class Recommended(Resource):
    @login_required
    def get(self):
        db = get_db()

        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)
        substring = request.args.get('substring')

        def get_recommended(tx, user_id):
            filterClause = generate_filter_clause(substring, False)
            return list(tx.run(f"MATCH (movie:Movie)-[is_predicted:IS_PREDICTED]->(user:User) WHERE user.userId = '{user_id}' AND (is_predicted.rejected IS NULL OR is_predicted.rejected <> True) {filterClause}WITH movie ORDER BY is_predicted.prediction DESC OPTIONAL MATCH (:User)-[overallRated:RATED]->(movie) WITH movie, avg(overallRated.rating) AS overallRated OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) AS genres, EXISTS((movie)-[:ON_WATCHLIST]->(:User {{userId: '{user_id}'}})) as on_watchlist, overallRated"))

        result = db.execute_write(get_recommended, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], result[i]['on_watchlist'], None, result[i]['overallRated']) for i in range(offset, offset + limit)])

class OnWatchlist(Resource):
    @login_required
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)
        substring = request.args.get('substring')

        def get_on_watchlist(tx, user_id):
            filterClause = generate_filter_clause(substring, False)
            return list(tx.run(f"MATCH (movie:Movie)-[on:ON_WATCHLIST]->(user:User) WHERE user.userId = '{user_id}' {filterClause}WITH movie OPTIONAL MATCH (:User)-[overallRated:RATED]->(movie) WITH movie, avg(overallRated.rating) as overallRated OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) OPTIONAL MATCH (:User {{userId: '{user_id}'}})-[rated:RATED]->(movie) RETURN movie, COLLECT(genre.name) as genres, rated, overallRated"))

        db = get_db()
        result = db.execute_write(get_on_watchlist, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], True, result[i]['rated'], result[i]['overallRated']) for i in range(offset, offset + limit)])

class Rated(Resource):
    @login_required
    def get(self):
        offset = try_parse_int(request.args.get('offset'), 0)
        limit = try_parse_int(request.args.get('limit'), 0)
        substring = request.args.get('substring')

        def get_rated(tx, user_id):
            filterClause = generate_filter_clause(substring, False)
            return list(tx.run(f"MATCH (user:User)-[rated:RATED]->(movie:Movie) WHERE user.userId = '{user_id}' {filterClause}WITH movie, rated OPTIONAL MATCH (:User)-[overallRated:RATED]->(movie) WITH movie, rated, avg(overallRated.rating) as overallRated OPTIONAL MATCH (movie)-[:IS_GENRE]->(genre:Genre) RETURN movie, COLLECT(genre.name) as genres, EXISTS((movie)-[:ON_WATCHLIST]->(:User {{userId: '{user_id}'}})) as on_watchlist, rated, overallRated"))

        db = get_db()
        result = db.execute_write(get_rated, g.user['userId'])

        offset, limit = check_offset_and_limit(result, offset, limit)

        return envelop_movies([serialize_movie(result[i]['movie'], result[i]['genres'], result[i]['on_watchlist'], result[i]['rated'], result[i]['overallRated']) for i in range(offset, offset + limit)])

class AddToWatchlist(Resource):
    @login_required
    def post(self, movieId):
        def add_to_watchlist(tx, movie_id, user_id):
            return tx.run(f"MATCH (movie:Movie) MATCH (user:User) WHERE movie.movieId = {movie_id} AND user.userId = '{user_id}' CREATE (movie)-[on_watchlist:ON_WATCHLIST]->(user)")

        db = get_db()
        result = db.execute_write(add_to_watchlist, movieId, g.user['userId'])
        return {}

class RemoveFromWatchlist(Resource):
    @login_required
    def post(self, movieId):
        def remove_from_watchlist(tx, movie_id, user_id):
            return tx.run(f"MATCH (movie:Movie)-[on_watchlist:ON_WATCHLIST]->(user:User) WHERE movie.movieId = {movie_id} AND user.userId = '{user_id}' DELETE on_watchlist")

        db = get_db()
        result = db.execute_write(remove_from_watchlist, movieId, g.user['userId'])
        return {}

alreadyStartedThreads = []

class Rate(Resource):
    @login_required
    def post(self, movieId):
        rating = request.args.get('rating')
        rating = float(rating) / 10.0

        def check_if_should_predict(tx, user_id):
            return tx.run(f"MATCH (user:User) WHERE user.userId = '{user_id}' OPTIONAL MATCH (user)-[rated:RATED]->(:Movie)  RETURN user, EXISTS((:Movie)-[:IS_PREDICTED]->(user)) as is_predicted_exists, count(rated) as ratedCount").single()
        
        def remove_from_watchlist(tx, user_id, movie_id):
            return tx.run(f"MATCH (movie:Movie)-[on_watchlist:ON_WATCHLIST]->(user:User) WHERE movie.movieId = {movie_id} AND user.userId = '{user_id}' DELETE on_watchlist")

        def unpredict(tx, user_id, movie_id):
            return tx.run(f"MATCH (movie:Movie)-[is_predicted:IS_PREDICTED]->(user:User) WHERE movie.movieId = {movie_id} AND user.userId = '{user_id}' DELETE is_predicted")

        def rate_movie(tx, user_id, movie_id, rating):
            return tx.run(f"MATCH (user:User) MATCH (movie:Movie) WHERE user.userId = '{user_id}' AND movie.movieId = {movie_id} CREATE (user)-[rated:RATED {{rating: {rating}}}]->(movie)")

        db = get_db()

        should_predict = db.execute_read(check_if_should_predict, g.user['userId'])

        result = db.execute_write(remove_from_watchlist,  g.user['userId'], movieId)
        result = db.execute_write(unpredict, g.user['userId'], movieId)
        result = db.execute_write(rate_movie, g.user['userId'], movieId, rating)
        
        user_id = should_predict['user']['id']
        def insert_user_prediction():
            predict(db, user_id)

        if not should_predict['is_predicted_exists'] and should_predict['ratedCount'] >= 4 and user_id not in alreadyStartedThreads:
            alreadyStartedThreads.append(user_id)
            predict_user_thread = Thread(target=insert_user_prediction)
            predict_user_thread.start()

        return {}

class Unrate(Resource):
    @login_required
    def post(self, movieId):
        def unrate_movie(tx, user_id, movie_id):
            return tx.run(f"MATCH (user:User)-[rated:RATED]-(movie:Movie) WHERE user.userId = '{user_id}' AND movie.movieId = {movie_id} DELETE rated")

        db = get_db()
        result = db.execute_write(unrate_movie, g.user['userId'], movieId)
        return {}

class Reject(Resource):
    @login_required
    def post(self, movieId):
        def reject_movie(tx, user_id, movie_id):
            return tx.run(f"MATCH (movie:Movie)-[is_predicted:IS_PREDICTED]->(user:User) WHERE user.userId = '{user_id}' AND movie.movieId = {movie_id} SET is_predicted.rejected = True")

        db = get_db()
        result = db.execute_write(reject_movie, g.user['userId'], movieId)
        return {}

class Unreject(Resource):
    @login_required
    def post(self, movieId):
        def unreject_movie(tx, user_id, movie_id):
            return tx.run(f"MATCH (movie:Movie)-[is_predicted:IS_PREDICTED]->(user:User) WHERE user.userId = '{user_id}' AND movie.movieId = {movie_id} SET is_predicted.rejected = False")

        db = get_db()
        result = db.execute_write(unreject_movie, g.user['userId'], movieId)
        return {}

class SignIn(Resource):
    def post(self):
        userId = request.args.get('userId')
        token = request.args.get('idToken')
        def get_user_by_user_id(tx, user_id):
            return tx.run(f"MATCH (user:User) WHERE user.userId = '{user_id}' RETURN user").single()

        db = get_db()
        result = db.execute_read(get_user_by_user_id, userId)

        if result is None:
            def create_user(tx, user_id, only_id):
                return tx.run(f"CREATE (user:User {{userId: '{user_id}', id: {only_id}}})")
            def get_max_user_id(tx):
                return tx.run(f"MATCH (user:User) RETURN max(user.id) as maxUserId").single()

            max_user_id = db.execute_read(get_max_user_id)

            result = db.execute_write(create_user, userId, max_user_id['maxUserId'] + 1)

        def set_token(tx, user_id, token):
            return tx.run(f"MATCH (user:User) WHERE user.userId = '{user_id}' SET user.token = '{token}'")

        result = db.execute_write(set_token, userId, token)

        return {}

api.add_resource(Movies, '/api/movies')
api.add_resource(Recommended, '/api/movies/recommended')
api.add_resource(OnWatchlist, '/api/movies/on_watchlist')
api.add_resource(Rated, '/api/movies/rated')
api.add_resource(AddToWatchlist, '/api/movies/<int:movieId>/add_to_watchlist')
api.add_resource(RemoveFromWatchlist, '/api/movies/<int:movieId>/remove_from_watchlist')
api.add_resource(Rate, '/api/movies/<int:movieId>/rate')
api.add_resource(Unrate, '/api/movies/<int:movieId>/unrate')
api.add_resource(Reject, '/api/movies/<int:movieId>/reject')
api.add_resource(Unreject, '/api/movies/<int:movieId>/unreject')
api.add_resource(SignIn, '/api/users/sign_in')

app.run(host=SERVER_HOST, port=SERVER_PORT)