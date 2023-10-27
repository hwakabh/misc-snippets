from typing import Literal

language_types = Literal['python', 'javascript']

def greeting(language: language_types) -> None:
    print(f'Hello, {language}')


if __name__ == '__main__':
    # Success
    greeting(language='python')
    # Unexpected
    greeting(language='ruby')
