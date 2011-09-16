# AutoWelcome

Connects to a twitter account and sends a pre-defined message to each new follower.

## About
* Need [twitter](https://github.com/jnunemaker/twitter) and [sqlite3](https://github.com/luislavena/sqlite3-ruby) modules
* Application need authorization to connect user's twitter account. See [twitter help](https://dev.twitter.com/docs/auth/oauth).
* Fill up 'config.yml' with twitter authorization token
* At the first start, application send message to each user's followers. After that

## Features

* Populate database with new followers

    populate

* Send welcome message to each new follower

    send_welcome_msg

* Each 10 scd, populate database with new follower and send them a welcome message

    live

## Exemple

    #!/usr/bin/env ruby
    require_relative 'autowelcome'

    tw = AutoWelcome.new
    tw.populate

## Author

Thibault Couraud

[http://sweetdub.com](http://sweetdub.com)
