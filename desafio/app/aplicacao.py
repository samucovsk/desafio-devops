from flask import Flask, request
import redis
from pymongo import MongoClient

app = Flask(__name__)

uri = "mongodb://localhost:27017/"
m = MongoClient(uri)
db = m.desafio
colecao = db["clientes"]

r = redis.Redis(host="localhost", port=6379, db=0)

@app.route("/")
def hello_world():
    count = r.incr("visitor_count")
    documento = {
        "ip": request.remote_addr,
        "contador": count,
        "user-agent": request.headers.get("User-Agent")
    }
    colecao.insert_one(documento)
    return f"<p> Hello, World!</p> <p> Numero de visitas: {count} </p> <p> IP: {request.remote_addr} </p> <p> user-agent: {request.headers.get("User-Agent")} </p>"

@app.route("/health_redis")
def health():
    """Verifica se os componentes estão funcionando """
    try:
        r.ping()
        m.admin.command("ping")
        return {"status": "healthy", "redis": "connected", "mongodb": "connected"}
    except Exception as e:
        raise Exception (
            "The following error occurred: ", e)


@app.route("/redis-data")
def redis_data():
    try:
        visitor_count = r.get("visitor_count")
        return f"o contador de visitas está {visitor_count}"
    except Exception as e:
        raise Exception (
            "The following error occurred: ", e)