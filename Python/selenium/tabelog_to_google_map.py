from selenium import webdriver
import os
import sys


def main(driver_path):
    URL = 'https://maps.google.com'
    driver = webdriver.Chrome(executable_path=driver_path)
    driver.get(URL)


if __name__ == "__main__":
    WEB_DRIVER_PATH = os.environ.get('WEB_DRIVER_PATH', None)

    if WEB_DRIVER_PATH is None:
        print('>>> Error, PATH of Chrome webdriver not set.')
        print('Set environmental variables with commands below, before running programs.')
        print()
        print('\texport WEB_DRIVER_PATH=\'PATH_TO_YOUR_WEB_DRIVER_BINARY\'')
        print()
        sys.exit(1)
    else:
        main(driver_path=WEB_DRIVER_PATH)
