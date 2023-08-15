[![Repo-GitHub](https://img.shields.io/badge/dynamic/xml?color=gold&label=GitHub%20module.xml&prefix=ver.&query=%2F%2FVersion&url=https%3A%2F%2Fraw.githubusercontent.com%2Fsergeymi37%2Fapptools-admin%2Fmaster%2Fmodule.xml)](https://raw.githubusercontent.com/sergeymi37/apptools-admin/master/module.xml)
[![OEX-zapm](https://img.shields.io/badge/dynamic/json?url=https:%2F%2Fpm.community.intersystems.com%2Fpackages%2Fapptools-admin%2F&label=ZPM-pm.community.intersystems.com&query=$.version&color=green&prefix=apptools-admin)](https://pm.community.intersystems.com/packages/apptools-admin)

[![Docker-ports](https://img.shields.io/badge/dynamic/yaml?color=blue&label=docker-compose&prefix=ports%20-%20&query=%24.services.iris.ports&url=https%3A%2F%2Fraw.githubusercontent.com%2Fsergeymi37%2Fapptools-admin%2Fmaster%2Fdocker-compose.yml)](https://raw.githubusercontent.com/sergeymi37/apptools-admin/master/docker-compose.yml)

## apptools-admin
[![OEX](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/apptools-admin) 
[![Demo](https://img.shields.io/badge/Demo%20on-Cloud%20Run%20Deploy-F4A460)](https://appadmin.demo.community.intersystems.com/apptoolsrest/a/info)

[![Habr](https://img.shields.io/badge/Available%20article%20on-Intersystems%20Community-orange)](https://community.intersystems.com/post/intersystems-solution-technical-support-and-dbms-interoperability-administration)
[![Habr](https://img.shields.io/badge/Есть%20статья%20на-Хабре-blue)](https://habr.com/en/post/436042/)

[![](https://img.shields.io/badge/InterSystems-IRIS-blue.svg)](https://www.intersystems.com/products/intersystems-iris/)
[![](https://img.shields.io/badge/InterSystems-Caché-blue.svg)](https://www.intersystems.com/products/cache/)
[![](https://img.shields.io/badge/InterSystems-Ensemble-blue.svg)](https://www.intersystems.com/products/ensemble/)

<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/SergeyMi37/apptools-admin">

[![license](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What's new

Added support Django framework.

![](https://raw.githubusercontent.com/SergeyMi37/apptools-admin/master/doc/Screenshot_10-at.png)

## Installation DJANGO
```
git clone https://github.com/SergeyMi37/apptools-django.git
cd apptools-django
```
Create virtual environment (optional)
```
python3 -m venv venv_dj
source venv_dj/bin/activate 
```
 For Windows `source venv_dj/Scripts/activate`

Install all requirements:
```
pip install -r requirements.txt
```
Create .env file in root directory and copy-paste this or just run cp .env_example .env, don't forget to change telegram token:
```
DJANGO_DEBUG=True
DATABASE_URL=sqlite:///db.sqlite3
TELEGRAM_TOKEN=<PASTE YOUR TELEGRAM TOKEN HERE>
ISC_Username=_system
ISC_Password=SYS
ISC_Namespace=USER
DJANGO_SUPERUSER_PASSWORD=demo
```
Run migrations to setup SQLite database:
```
python manage.py migrate
```
Create superuser to get access to admin panel:
```
python manage.py createsuperuser --noinput --username admin --email admin@localhost.com
```
Run bot in polling mode:
```
python run_polling.py
```
If you want to open Django admin panel which will be located on `http://localhost:8000/tgadmin/`
```
python manage.py runserver
```
## Installation with ZPM

If the current ZPM instance is not installed, then in one line you can install the latest version of ZPM even with a proxy.
```
s r=##class(%Net.HttpRequest).%New(),proxy=$System.Util.GetEnviron("https_proxy") Do ##class(%Net.URLParser).Parse(proxy,.pr) s:$G(pr("host"))'="" r.ProxyHTTPS=1,r.ProxyTunnel=1,r.ProxyPort=pr("port"),r.ProxyServer=pr("host") s:$G(pr("username"))'=""&&($G(pr("password"))'="") r.ProxyAuthorization="Basic "_$system.Encryption.Base64Encode(pr("username")_":"_pr("password")) set r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")
```
If ZPM is installed, then ZAPM can be set with the command
```
zpm:USER>install apptools-admin
```
## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/SergeyMi37/apptools-admin.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it
Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>
USER>zpm
zpm:USER>install apptools-admin
```