import csv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
import pyperclip


FACEBOOK_ID = 'hrykwkbys1024@yahoo.co.jp'
FACEBOOK_PASSWORD = 'gaku1991'


driver = webdriver.Chrome(executable_path='/Users/hwakabayashi/chromedriver')
driver.get('https://tabelog.com/')
# Login with Facebook account
driver.find_element_by_class_name('js-open-login-modal').click()
driver.find_element_by_class_name('p-login-panel__btn--facebook').click()
driver.find_element_by_id('email').send_keys(FACEBOOK_ID)
driver.find_element_by_id('pass').send_keys(FACEBOOK_PASSWORD)
driver.find_element_by_id('loginbutton').click()

driver.find_element_by_class_name('p-user-menu__target--hozon').click()

restaurants = []
while True:
    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.CLASS_NAME, 'js-copy-restaurant-info-to-clipboard')))
    clipboard_buttons = driver.find_elements_by_class_name('js-copy-restaurant-info-to-clipboard')
    for button in clipboard_buttons:
        button.click()
        data = pyperclip.paste().split('\n')
        if len(data) < 4:
            data.insert(1, '')
        map_url = 'https://www.google.co.jp/maps/search/' + ' '.join(data[0:3])
        data.append(map_url)
        restaurants.append(data)
    try:
        driver.find_element_by_class_name('c-pagination__arrow--next').click()
    except NoSuchElementException:
        break

with open('result.csv', 'wt', encoding='utf_8_sig') as f:
    writer = csv.writer(f, quoting=csv.QUOTE_ALL)
    writer.writerows(restaurants)

print('>>> Done.')
driver.quit()
