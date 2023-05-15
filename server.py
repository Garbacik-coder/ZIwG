import socket
import re
import os
import threading
import pandas as pd
from urllib.parse import urlparse
from urllib.parse import parse_qs
from neo4j import GraphDatabase

header_re = re.compile(r"(GET|POST) ([^ ]+) HTTP/", re.I)

def connect_to_db(uri, user, password):
    return GraphDatabase.driver(uri, auth=(user, password))

def get_request_data(socket):
    request = []
    while True:
        data = socket.recv(100)
        data = data.decode("utf-8") 
        request.append(data)
        if len(data) < 100:
            break
    return "".join(request).split("\r\n\r\n", 1)[0]

def response(code, data, mime = "text/plain", headers = None):
    response_headers = {
        "Server": "Python",
        "Content-Type": mime,
        "Content-Length": len(data),
        "Connection": "close"
    }
    if headers:
        response_headers.update(headers)
    headers = "\r\n".join([ "%s: %s" % (k,v) for k, v in response_headers.items()])
    res = "HTTP/1.1 %s\r\n%s\r\n\r\n%s"
    return bytes(res % ('404', headers, data), 'utf-8')

def run_rate(tx, userId, movieId, rating):
    result = tx.run(f"MATCH (u:User) MATCH (m:Movie) WHERE u.userId = {userId} AND m.movieId = {movieId} CREATE (u)-[r:RATED {{rating: {rating}}}]->(m) ")

def rate(userId, movieId, rating):
    driver = connect_to_db("bolt://localhost:7687", "neo4j", "12345678")
    with driver.session() as session:
        session.execute_write(run_rate, userId, movieId, rating)
    driver.close()

def handle_request(request):
    if '/api/movies/' in request:
        content = request.replace('/api/movies/', '')
        userId = int(re.search(r'\d+', content).group())
        parsed_url = urlparse(content)
        movieId = parse_qs(parsed_url.query)['movieId'][0]
        rating =  parse_qs(parsed_url.query)['rating'][0]
        rate(userId, movieId, rating)

def handler(socket):
    global header_re
    raw_request = get_request_data(socket)
    request = raw_request.split()
    handle_request(request[1])
    socket.close()

try:
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", 8080))
    server.listen(5)
    while True:
        client, addr = server.accept()
        client_handler = threading.Thread(target = handler, args=(client,))
        client_handler.start()
except KeyboardInterrupt:
    server.close()
