# Selenium workouts

## Environments

All the Python programs in this sub-directory are expected to run correctly under the environments below:

| Components | Version |
| --- | --- |
| OS | 10.15.4 (Catalina) |
| Python | 3.6.4 with pyenv |
| Selenium | 3.141.0 |
| Google Chrome | 81.0.4044.122 Official Build (64-bit) |

***

## Installation & Setup

### Installation

Firstly it's required to install `selenium` package.  
If you use `virtualenv`, create your private virtual environment first, and install the selenium pacakge with pip.  

```bash
# If you use virtual env: run `source ENV_NAME/bin/activate` first
pip install selenium
```

### Setup webdriver

Secondary, we need to install Chrome webdriver to your enviroment, where the program runs.  
We can install the packages with package manager like `brew`, or download from the sites <https://sites.google.com/a/chromium.org/chromedriver/downloads> .  

```bash
brew cask install chromedriver
```

Also, since the Python scripts will try to fetch environmental variables in the codes,  
we need to set environmental variables of selenium chrome driver.  
For example of `bash`, follow the commands below:

```bash
export SELENIUM_PATH='PATH_TO_YOUR_CHROME_DRIVER_BINARY'
# For example with your parameters
# export SELENIUM_PATH='$HOME/chromedriver'
```
