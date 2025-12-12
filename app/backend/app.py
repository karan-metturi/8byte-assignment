from flask import Flask
import os
import psycopg2
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from ECS Fargate"
@app.route("/db")
def db_test():
    try:
        conn = psycopg2.connect(
            host=os.environ["DB_HOST"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"],
            dbname=os.environ["DB_NAME"],
            port=os.environ["DB_PORT"]
        )
        conn.close()
        return "Database connection successeful!"
    except Exception as e:
        return f"Database connection failed: {e}"
    

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)