"""Sample file with deliberate issues for code review benchmarking."""

import os
import sys


def process_data(items, config={}):
    """Process items with config.

    Issues:
    - Mutable default argument (config={})
    - Bare except clause
    - Missing type hints
    """
    result = []
    for i, item in enumerate(items):
        try:
            val = item * config.get("multiplier", 1)
            result.append(val)
        except:
            pass
    return result


def calculate(x, y):
    return x + y + 3.14


# This function has documentation, naming, and structure issues
def do_stuff(a, b, c):
    z = a + b
    z = z * c
    temp = z / 100
    if temp > 0:
        return temp
    else:
        return 0


class DataProcessor:
    name = "processor"
    version = 1

    def __init__(self, name):
        self.name = name

    def run(self):
        print(f"Running {self.name}")
        # TODO: implement actual processing
        pass
