from bs4 import BeautifulSoup
# require: pip install google-cloud-translate==2.0.1
from google.cloud import translate_v2 as translate
import os
import requests

# Setup for Scraping
target_url = 'https://dangcongsan.vn/thoi-su'
h = {'User-Agent': 'Mozilla'}

# Setup for Translate API
print('>> Translator client instanciated')
client = translate.Client()

GOOGLE_APPLICATION_CREDENTIALS = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS', None)
if GOOGLE_APPLICATION_CREDENTIALS is None:
    print('Error: No credentials file provided')


print(f'>> Starting to scrape HTML from {target_url}')

print('>> Fetching all HTML data from the target')
html = requests.get(headers=h, url=target_url)

print('>>> Instantiate bs4')
soup = BeautifulSoup(html.text, 'html.parser')
# print('DEBUG: BeautifulSoup object created')

print('>> Collecting tags latest news ...')
news = soup.find_all('div', {'class': 'pcontent3'})
# print(type(news)) ---> <class 'bs4.element.ResultSet'>

print('>> Iterate all latest news, this might take some times ...')
for n in news:
    print('---')
    # print(type(n)) ---> <class 'bs4.element.Tag'>
    # note that `find()` returns only first element which hit the conditions
    date = n.find('div', {'class': 'i-date'}).text
    print(f'Date Published: {date}')
    article_fullpath = n.find('a').attrs['href']
    print(f'Pull article path:  {article_fullpath}')
    image_path = n.find('div').find('img').attrs['src']
    print(f'Image src Path:   {image_path}')
    print('')

    title = n.find('a').attrs['title']
    print(f'Article Title:    {title}')
    ret_title = client.translate(title, target_language='ja')['translatedText']
    print(f'Article Title(JP):   {ret_title}')
    print('')
    catch_text = n.find('span').text
    print(f'Header Text :\n{catch_text}')
    ret_text = client.translate(catch_text, target_language='ja')['translatedText']
    print(f'Header Text(JP):\n{ret_text}')
    print('')
