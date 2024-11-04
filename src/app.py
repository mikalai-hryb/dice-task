import os
import random
from datetime import datetime, timezone
import csv

from flask import Flask, Response, request


app = Flask(__name__)


DEFAULT_PORT = 8080
DEFAULT_CSV_FILE_PATH = os.path.join(app.root_path, '..', 'assets', 'dice.csv')

PORT = os.environ.get('DICE_APP_PORT', DEFAULT_PORT)
CSV_FILE_PATH = os.environ.get(
    'DICE_APP_CSV_FILE_PATH', DEFAULT_CSV_FILE_PATH)
PATH_PREFIX = os.environ.get('DICE_APP_PATH_PREFIX', '')  # example: "app"
PATH_PREFIX = f"/{PATH_PREFIX}" if PATH_PREFIX else ''


print('PORT: ', PORT)
print('CSV_FILE_PATH: ', CSV_FILE_PATH)
print('PATH_PREFIX: ', PATH_PREFIX)


@app.route("/")
def hello_world():
    return f"""
        <h1>Dice App</h1>
        <ul>
            <li><a href="{PATH_PREFIX}/health">/health</a> - whether the app is alive</li>
            <li><a href="{PATH_PREFIX}/dice">/dice</a> - generates a random number between 1-6</li>
            <li><a href="{PATH_PREFIX}/history">/history</a> - displays the history of the <b><i>{PATH_PREFIX}/dice</i></b> calls made in this browser</li>
            <li><a href="{PATH_PREFIX}/clear">/clear</a> - clear the history of <b><i>{PATH_PREFIX}/dice</i></b> calls made in this browser</li>
        </ul>
"""


@app.route("/health")
def health():
    return Response("I am alive!", status=200)


@app.route("/dice")
def dice():
    isoformat_datetime = datetime.now(timezone.utc).isoformat()
    point = random.randint(1, 6)
    user_agent = request.headers.get('User-Agent')

    with open(CSV_FILE_PATH, "a") as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow([isoformat_datetime, point, user_agent])

    return Response(str(point), status=200)


@app.route("/history")
def history():
    empty_response = Response("It's empty! Try <a href=\"/dice\">/dice</a> first!", status=200)
    try:
        with open(CSV_FILE_PATH, "r") as csv_file:
            current_user_agent = request.headers.get('User-Agent')
            if current_user_agent:
                events = []

                reader = csv.reader(csv_file)
                for row in reader:
                    timestamp, point, user_agent = row
                    if current_user_agent.strip() == user_agent.strip():
                        events.append(f"<li>[{timestamp}] {point}</li>")
                print('events', events)
                if events:
                    history_html = "<ol>\n" + "\n".join(events) + "</ol>\n"
                    return Response(history_html, status=200)
    except FileNotFoundError:
        return empty_response

    return empty_response


@app.route("/clear")
def clear():
    try:
        with open(CSV_FILE_PATH, "r+") as csv_file:
            current_user_agent = request.headers.get('User-Agent')
            if current_user_agent:
                events = []

                reader = csv.reader(csv_file)
                for row in reader:
                    _timestamp, _point, user_agent = row
                    if current_user_agent.strip() != user_agent.strip():
                        events.append(row)

                csv_file.seek(0)
                csv_file.truncate()

                writer = csv.writer(csv_file)
                writer.writerows(events)

                return Response("History successfully cleared!", status=200)

        return Response("Cannot identify the user!", status=400)

    except FileNotFoundError:
        return Response(status=204)


def initialize_app():
    os.makedirs(os.path.dirname(CSV_FILE_PATH), exist_ok=True)
    if not os.path.exists(CSV_FILE_PATH):
        with open(CSV_FILE_PATH, 'w'):
            pass


if __name__ == "__main__":
    initialize_app()
    app.run(host="0.0.0.0", port=PORT)
