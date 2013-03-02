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
    client = Rex11::Client.new("rex_username", "rex_password", "rex_web_address")

Create style master:

    item = {
        :style => "ABC123",
        :upc => "ABC123",
        :size => "LARGE",
        :price => "100.0",
        :color => "Black",
        :description => "Chanel Red Skirt"
    }

    client.add_styles_for_item(item)

Create pick ticket for items:

    items = [
        {:style => "ABC123",
         :upc => "ABC123",
         :size => "LARGE",
         :color => "Black",
         :description => "Chanel Red Skirt",
         :quantity => "1",
         :comments => "These are the comments.",
         :shipment_type => "GOH"
        },
        {:style => "DEF123",
         :upc => "DEF123",
         :size => "SMALL",
         :color => "Blue",
         :description => "Balenciaga Purple Blouse",
         :quantity => "1",
         :comments => "Slightly damaged",
         :shipment_type => "FLAT"
        }
    ]

    ship_to_address = {:first_name => "Joe",
                        :last_name => "Shmoe",
                        :company_name => "Time Magazine",
                        :address1 => "1271 Avenue of the Americas",
                        :city => "New York",
                        :state => "NY",
                        :zip => "10020",
                        :country => "US",
                        :phone => "212-522-1212",
                        :email => "time@magazine.com"
    }

    pick_ticket_number = "23022012012557"
    pick_ticket_options = {
        :pick_ticket_number => pick_ticket_number,
        :warehouse => "The Warehouse",
        :payment_terms => "NET",
        :use_ups_account => "1",
        :ship_via_account_number => "1AB345",
        :ship_via => "UPS",
        :ship_service => "UPS GROUND - Commercial",
        :billing_option => "PREPAID",
        :bill_to_address => {
            :first_name => "Jane",
            :last_name => "Smith",
            :company_name => "Netaporter",
            :address1 => "725 Darlington Avenue",
            :city => "Mahwah",
            :state => "NJ",
            :zip => "07430",
            :country => "US",
            :phone => "212-522-1212",
            :email => "net@netaporter.com"
        }
    }

    client.create_pick_tickets_for_items(items, ship_to_address, pick_ticket_options)





## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
