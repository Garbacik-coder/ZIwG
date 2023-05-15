from flask import Flask, request, jsonify

app = Flask(__name__)

countries = [
    {"id": 1, "name": "Thailand", "capital": "Bangkok", "area": 513120},
    {"id": 2, "name": "Australia", "capital": "Canberra", "area": 7617930},
    {"id": 3, "name": "Egypt", "capital": "Cairo", "area": 1010408},
]

def _find_next_id():
    return max(country["id"] for country in countries) + 1

# @app.get("/countries")
# def get_countries():
#     return jsonify(countries)

@app.post("/api/movies/{uid}/watchlistAdd")
def add_to_watchlist():
    # ciąg dalszy nastąpi

    # if request.is_json:
    #     country = request.get_json()
    #     country["id"] = _find_next_id()
    #     countries.append(country)
    #     return country, 201
    # return {"error": "Request must be JSON"}, 415