import os

from bs4 import BeautifulSoup
import requests


target_url = 'https://note.wrl.co.jp/n/n3d8a2d666a83'
download_dir = './contents'
h = {'User-Agent': 'Mozilla'}

print(f'>> Starting to scrape HTML from {target_url}')
if not os.path.exists(download_dir):
    os.mkdir(download_dir)

print('>> Fetching all HTML data from the target')
html = requests.get(headers=h, url=target_url)

print('>>> Instantiate bs4')
soup = BeautifulSoup(html.text, 'html.parser')
print('DEBUG: BeautifulSoup object created')

print('>> Collecting tags related images ...')
images = soup.find_all("img")

print('>> Iterate all images, this might take some times ...')
for img in images:
    if 'data-src' in img.attrs:
        ds = img.attrs['data-src'].replace('?width=800', '?width=1600')

        file_name = ds.split('/')[-1].split('?')[0]
        dl_path = os.path.join(download_dir, file_name)

        i = requests.get(headers=h, url=ds)
        with open(dl_path, 'wb') as f:
            print(f'Saved {dl_path}')
            f.write(i.content)

    else:
        print('>>>> Attribute data-src do not exist, skipped.')
