from selenium import webdriver

# Instanciate with path to chromedriver binary
driver = webdriver.Chrome(executable_path='/Users/hwakabayashi/chromedriver')
driver.get('https://google.co.jp')

print('>>> Opening Chrome driver done.')
driver.quit()