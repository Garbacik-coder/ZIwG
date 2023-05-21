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

class RateMovie(Resource):
    def post(self, movieId):
        userId = request.args.get("userId")
        rating = request.args.get("rating")

        def rate_movie(tx, user_id, movie_id, rating):
            return tx.run(f"MATCH (u:User) MATCH (m:Movie) WHERE u.userId = {user_id} AND m.movieId = {movie_id} CREATE (u)-[r:RATED {{rating: {rating}}}]->(m)")

        db = get_db()
        results = db.write_transaction(rate_movie, userId, movieId, rating)
        return {}

api.add_resource(RateMovie, '/api/movies/<int:movieId>/rate')

app.run(host=SERVER_HOST, port=SERVER_PORT)