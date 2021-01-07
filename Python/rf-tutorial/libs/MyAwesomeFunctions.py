from robot.api import logger


def print_hello_to_stdout():
    logger.console('Hello')


def greet_to_console(key='default'):
    logger.console(f'hello world from {key} !!')


def print_company_info(name, code, year, founder):
    logger.console(f'Company: {name}({code}), established by {founder} in {year} ')
