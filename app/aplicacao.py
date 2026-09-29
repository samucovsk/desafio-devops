from flask import Flask, request
import redis
from pymongo import MongoClient

app = Flask(__name__)

uri = "mongodb://localhost:27017/"
m = MongoClient(uri)
db = m.desafio
colecao = db["clientes"]

r = redis.Redis(host="localhost", port=6379, db=0)
try:

    m.admin.command("ping")
    print("Conectado com sucesso!")

except Exception as e:
    raise Exception(
        "O erro a seguir aconteceu: ", e)

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

