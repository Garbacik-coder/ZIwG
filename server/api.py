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

class Rate(Resource):
    def post(self, movieId):
        userId = request.args.get('userId')
        rating = request.args.get('rating')

        def rate_movie(tx, user_id, movie_id, rating):
            return tx.run(f'MATCH (u:User) MATCH (m:Movie) WHERE u.userId = {user_id} AND m.movieId = {movie_id} CREATE (u)-[r:RATED {{rating: {rating}}}]->(m)')

        db = get_db()
        result = db.execute_write(rate_movie, userId, movieId, rating)
        return {}

class Unrate(Resource):
    def post(self, movieId):
        userId = request.args.get('userId')

        def unrate_movie(tx, user_id, movie_id):
            return tx.run(f'MATCH (u:User)-[r:RATED]-(m:Movie) WHERE u.userId = {user_id} AND m.movieId = {movie_id} DELETE r')

        db = get_db()
        result = db.execute_write(unrate_movie, userId, movieId,)
        return {}

api.add_resource(Movies, '/api/movies')
api.add_resource(Rate, '/api/movies/<int:movieId>/rate')
api.add_resource(Unrate, '/api/movies/<int:movieId>/unrate')

app.run(host=SERVER_HOST, port=SERVER_PORT)