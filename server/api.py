from flask import Flask, g, request
from flask_restful import Resource, Api
from neo4j import GraphDatabase

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

SERVER_HOST = '0.0.0.0'
SERVER_PORT = 8080

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

app = Flask(__name__)
api = Api(app)


def get_db():
    if not hasattr(g, 'neo4j_db'):
        g.neo4j_db = driver.session()
    return g.neo4j_db


def close_db(error):
    if hasattr(g, 'neo4j_db'):
        g.neo4j_db.close()


def serialize_movie(movie):
    return {
        'movieId': movie['movieId'],
        'title': movie['title'],
    }


class Movies(Resource):
    def get(self):
        offset = int(request.args.get('offset'))
        limit = int(request.args.get('limit'))

        def get_movies(tx):
            return list(tx.run('MATCH (movie:Movie) RETURN movie'))

        db = get_db()
        result = db.execute_write(get_movies)

        return [serialize_movie(result[i]['movie']) for i in range(offset, offset + limit)]


class Recommended(Resource):
    def get(self):
        user_id = request.args.get('userId')
        offset = int(request.args.get('offset'))
        limit = int(request.args.get('limit'))

        # def get_recommended(tx):
        # return list(tx.run('MATCH ()'))


class OnWatchlist(Resource):
    def get(self):
        user_id = request.args.get('userId')
        offset = int(request.args.get('offset'))
        limit = int(request.args.get('limit'))

        def get_on_watchlist(tx, user_id):
            return list(tx.run(
                f'MATCH (movie:Movie)-[on:ON_WATCHLIST]->(user:User) WHERE user.userId = {user_id} RETURN movie'))

        db = get_db()
        result = db.execute_write(get_on_watchlist, user_id)

        return [serialize_movie(result[i]['movie']) for i in range(offset, offset + limit)]


class Rated(Resource):
    def get(self):
        user_id = request.args.get('userId')
        offset = int(request.args.get('offset'))
        limit = int(request.args.get('limit'))

        def get_rated(tx, user_id):
            return list(
                tx.run(f'MATCH (user:User)-[rated:RATED]->(movie:Movie) WHERE user.userId = {user_id} RETURN movie'))

        db = get_db()
        result = db.execute_write(get_rated, user_id)

        return [serialize_movie(result[i]['movie']) for i in range(offset, offset + limit)]


class AddToWatchlist(Resource):
    def post(self, movieId):
        user_id = request.args.get('userId')

        def add_to_watchlist(tx, movie_id, user_id):
            return tx.run(
                f'MATCH (movie:Movie) MATCH (user:User) WHERE movie.movieId = {movie_id} AND user.userId = {user_id} CREATE (movie)-[on_watchlist:ON_WATCHLIST]->(user)')

        db = get_db()
        result = db.execute_write(add_to_watchlist, movieId, user_id)
        return {}


class RemoveFromWatchlist(Resource):
    def post(self, movieId):
        user_id = request.args.get('userId')

        def remove_from_watchlist(tx, movie_id, user_id):
            return tx.run(
                f'MATCH (movie:Movie)-[on_watchlist:ON_WATCHLIST]->(user:User) WHERE movie.movieId = {movie_id} AND user.userId = {user_id} DELETE on_watchlist')

        db = get_db()
        result = db.execute_write(remove_from_watchlist, movieId, user_id)
        return {}


class Rate(Resource):
    def post(self, movieId):
        user_id = request.args.get('userId')
        rating = request.args.get('rating')

        def rate_movie(tx, user_id, movie_id, rating):
            return tx.run(
                f'MATCH (user:User) MATCH (movie:Movie) WHERE user.userId = {user_id} AND movie.movieId = {movie_id} CREATE (user)-[rated:RATED {{rating: {rating}}}]->(movie)')

        db = get_db()
        result = db.execute_write(rate_movie, user_id, movieId, rating)
        return {}


class Unrate(Resource):
    def post(self, movie_id):
        user_id = request.args.get('userId')

        def unrate_movie(tx, user_id, movie_id):
            return tx.run(
                f'MATCH (user:User)-[rated:RATED]-(movie:Movie) WHERE user.userId = {user_id} AND movie.movieId = {movie_id} DELETE rated')

        db = get_db()
        result = db.execute_write(unrate_movie, user_id, movie_id, )
        return {}


class AddNewUser(Resource):
    def post(self, user_id):

        def create_user(tx, user_id):
            tx.run(f'CREATE (user:User) SET user.userId = {user_id}')

        db = get_db()
        db.create_user(create_user, user_id)
        return {}


api.add_resource(Movies, '/api/movies')
api.add_resource(OnWatchlist, '/api/movies/on_watchlist')
api.add_resource(Rated, '/api/movies/rated')
api.add_resource(AddToWatchlist, '/api/movies/<int:movieId>/add_to_watchlist')
api.add_resource(RemoveFromWatchlist, '/api/movies/<int:movieId>/remove_from_watchlist')
api.add_resource(Rate, '/api/movies/<int:movieId>/rate')
api.add_resource(Unrate, '/api/movies/<int:movieId>/unrate')
api.add_resource(AddNewUser, '/api/user/<int:userId>/add_new_user')

app.run(host=SERVER_HOST, port=SERVER_PORT)
