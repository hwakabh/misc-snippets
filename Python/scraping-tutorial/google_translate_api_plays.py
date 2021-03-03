from google.cloud import translate_v2 as translate

# Ref: https://qiita.com/ekzemplaro/items/7b0cb663e432160654b8
print('>> Translator client instanciated')
client = translate.Client()

srctext = '''
​(ĐCSVN) - Bản tin 18 giờ ngày 2/3 của Ban Chỉ đạo Quốc gia Phòng chống dịch COVID-19 cho biết, không có ca mắc COVID-19. Như vậy, đã 12 giờ qua, Việt Nam chưa ghi nhận ca mắc mới.
'''
print('Source Text:')
print(srctext)

ret = client.translate(srctext, target_language='ja')

print('Translated Text:\n')
print(ret['translatedText'])
