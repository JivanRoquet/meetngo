# -*- coding: utf-8 -*-

import meetngo
import os
import json

def load_events_file():
    path = meetngo.__path__[0]
    events_file = os.path.join(path, 'data', 'events_old.json')
    events_file_content = open(events_file, encoding='utf-8')
    events = json.loads(events_file_content.read())
    return events
