# Rex11

Ruby Library for REX11 Warehouse Management System

## Installation

Add this line to your application's Gemfile:

    gem 'rex11'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rex11

## Usage

Initialize Rex11 client:

    require "rex11"
    client = Rex11::Client.new("rex_username", "rex_password")

Create style master:

    client.add_styles_for_item(item)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
