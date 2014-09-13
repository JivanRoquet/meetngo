from flask import Flask, render_template
from . import template_func, utils

meetngo = Flask('meetngo')

@meetngo.route('/')
def index():
    events = utils.load_events_file()
    return render_template("index.html", events=events)
