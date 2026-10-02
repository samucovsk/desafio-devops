from flask import Flask, request
import redis
from pymongo import MongoClient
import os

app = Flask(__name__)

redis_url = os.getenv("REDIS_URL", "redis://localhost:6379")
r = redis.from_url(redis_url)

mongo_url = os.getenv("MONGO_URL", "mongodb://root:root@localhost:27017")
m = MongoClient(mongo_url)
db = m.desafio
colecao = db["clientes"]

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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)