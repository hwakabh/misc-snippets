from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.common.by import By

import os
import sys
import time


def main(driver_path):
    # Open Chrome with google account
    URL = 'https://www.google.com/accounts?hl=ja-JP'
    GOOGLE_USERNAME = os.environ.get('GOOGLE_USERNAME', None)
    GOOGLE_PASSWORD = os.environ.get('GOOGLE_PASSWORD', None)

    driver = webdriver.Chrome(executable_path=driver_path)
    driver.get(URL)
    WAIT_TIME = 30

    if (GOOGLE_USERNAME is not None) and (GOOGLE_PASSWORD is not None):
        # Get X-PATH for Username
        xpath_username = '//*[@id="identifierNext"]'
        WebDriverWait(driver, WAIT_TIME).until(ec.presence_of_element_located((By.XPATH, xpath_username)))
        # Enter username(email address)
        driver.find_element_by_name("identifier").send_keys(GOOGLE_USERNAME)
        driver.find_element_by_xpath(xpath_username).click()

        # Get X-Path for Password
        xpath_password = '//*[@id="passwordNext"]'
        WebDriverWait(driver, WAIT_TIME).until(ec.presence_of_element_located((By.XPATH, xpath_password)))
        # Enter password
        driver.find_element_by_name("password").send_keys(GOOGLE_PASSWORD)

        time.sleep(1)
        driver.find_element_by_xpath(xpath_password).click()
    else:
        driver.quit()
        print('>>> Error, Password for Google account not set.')
        print('Set environmental variables with commands below, before running programs.')
        print()
        print('\texport GOOGLE_USERNAME=\'YOUR_GOOGLE_USERNAME\'')
        print('\texport GOOGLE_PASSWORD=\'YOUR_GOOGLE_PASSWORD\'')
        print()
        sys.exit(1)


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
        print('>>> Starting to program !!')
        main(driver_path=WEB_DRIVER_PATH)
