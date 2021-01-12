# RobotFramework tutorials

## Environments

All the Python programs in this sub-directory are expected to run correctly under the environments below:

| Components | Version |
| --- | --- |
| OS | 10.15.7 (Catalina) |
| Python | 3.8.2 with pyenv |

Note that the Python packages versions are noted in `requirements.txt`, and Python version itself is in `.python-version`, which is configuration file of `pyenv`, software of Python version controlling.  

## Setting up

- Installation

```bash
# (Optional) If you'd like to use `venv` for creating independent packaging environment, create virtual environment first.
$ python -m venv ${YOUR_VIRTUAL_ENV_NAME}
$ source ./{YOUR_VIRTUAL_ENV_NAME}/bin/activate

# Installating dependencies for Python
$ pip install -r requirements.txt
# (Optional) Install pip version if needed
$ pip install --upgrade pip
```

- Selenium configurations  
If you try to `SeleniumLibrary`, external libraries of RobotFramework, it's required to install Google Chrome application, and you have to configure its drivers with `webdrivermanager` packages.  
You can use `webdrivermanager` command, after installing `pip install webdrivermanager`, and `webdrivermanger` command will download compatible driver's binary for your environment, and set the `PYTHONPATH` for running them.  

```bash
$ webdrivermanager chrome
Downloading WebDriver for browser: "chrome"
Driver binary downloaded to: "PATH_OF_YOUR_WORKSPACE/chromedriver"
Symlink created: PATH_OF_YOUR_WORKSPACE/chromedriver
```

Note that `webdrivermanager` will configure appropriate `PYTHONPATH` even if you'd use virtualenv for robotframeowork.  
Default path if you using virtualenv will be: `PATH_OF_YOUR_WORKSPACE/venv/bin/chromedriver`
