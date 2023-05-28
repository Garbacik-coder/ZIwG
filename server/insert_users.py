from neo4j import GraphDatabase

DATABASE_USERNAME = 'neo4j'
DATABASE_PASSWORD = '12345678'
DATABASE_URL = 'bolt://localhost:7687'

driver = GraphDatabase.driver(DATABASE_URL, auth=(DATABASE_USERNAME, DATABASE_PASSWORD))

def insert_user(tx, user_id):
    return list(tx.run(f'CREATE (user:User) SET user.userId = {user_id}'))

with driver.session() as db:
    for i in range(0, 66):
        user_id = i
        result = db.execute_write(insert_user, user_id)
        print(user_id)
