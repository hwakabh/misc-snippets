def greetings(name: str = 'python') -> str:
    return 'hello ' + name


if __name__ == '__main__':
    username: str = 'hiroyuki'
    print(greetings(name=username))

