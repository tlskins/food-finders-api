# TasteBuds Api
Rails JSON API for TasteBuds. Using Mongodb and Redis.

Dependencies:

* Rails version - 5.1.5
* Ruby version - 2.5.0
* System dependencies
  - Redis
  - Mongodb

## Getting Setup

### Install RVM

```
\curl -sSL https://get.rvm.io | bash -s stable --ruby
rvm install ruby-2.5.0
```

### Clone the Repo

```
git clone https://github.com/tlskins/food-finders-api.git
```

### Install Mongodb server

```
(on Ubuntu 16.04)
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start
```

### Install Gems

```
gem install bundler
bundle install
```

### Install [Pow.cx](http://pow.cx)

We use [Powder](https://github.com/powder-rb/powder) to manage Pow.

```
powder install
powder link
```

`powder link` will create a symlink using the value in `.powder`

## Background Jobs - Redis

To install Redis

```
brew install redis
```

To start redis server from config file:

```
redis-server /usr/local/etc/redis.conf
```
