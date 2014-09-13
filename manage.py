import os, sys 

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from flask.ext.script import Manager, Server
from meetngo import meetngo

manager = Manager(meetngo)

manager.add_command("runserver", Server(
        use_debugger = True,
        use_reloader = True,
        host = '127.0.0.1',
        port = 8080) 
)

if __name__ == '__main__':
        manager.run()
