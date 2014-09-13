# -*- coding: utf-8 -*-

import meetngo
import os
import json

def load_events_file():
    path = meetngo.__path__[0]
    events_file = os.path.join(path, 'data', 'events.json')
    events_file_content = open(events_file)
    events = json.loads(events_file_content.read())
    return events
