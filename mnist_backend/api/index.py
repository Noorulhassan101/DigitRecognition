import sys
import os

# Add the parent directory to sys.path so server can be imported
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from server import app
