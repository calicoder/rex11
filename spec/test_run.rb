require 'rex11'

USERNAME = "yoram"
PASSWORD = "not_set"
WEB_ADDRESS = "www.yoramtestaccount.atworkweb.com"

TESTING = true

item = {
    :style => "ABC123",
    :upc => "ABC123",
    :size => "LARGE",
    :price => "100.0",
    :color => "Black",
    :description => "Chanel Red Skirt"
}
item2 = {
    :style => "DEF123",
    :upc => "DEF123",
    :size => "LARGE",
    :price => "100.0",
    :color => "Purple",
    :description => "Chanel Red Blouse"
}

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

pick_ticket_id = "23022012012557"
pick_ticket_options = {
    :pick_ticket_id => pick_ticket_id,
    :warehouse => "BERGEN LOGISTICS NJ",
    :payment_terms => "NET",
    :use_ups_account => "0",
    #:ship_via_account_number => "1AB345",
    :ship_via => "UPS",
    :ship_service => "UPS GROUND - Commercial",
    :billing_option => "THIRD PARTY",
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
receiving_ticket_options = {
    :warehouse => "BERGEN LOGISTICS NJ",
    :carrier => "the_carrier",
    :memo => "the_memo",
    :supplier => {:company_name => "Netaporter",
                  :address1 => "725 Darlington Avenue",
                  :city => "Mahwah",
                  :state => "NJ",
                  :zip => "07430",
                  :country => "US",
                  :phone => "212-522-1212",
                  :email => "net@netaporter.com"
    }
}

puts "Authenticating...."
client = Rex11::Client.new(USERNAME, PASSWORD, WEB_ADDRESS, TESTING, :logging => false)
result = client.authenticate
puts "Authenticated: #{result}\n\n"

puts "Creating Style Master...."
result = client.add_style(item)
puts "Added Style Master: #{result}"

puts "Creating Style Master...."
result = client.add_style(item2)
puts "Added Style Master: #{result}\n\n"

puts "Creating Pick Ticket..."
response = client.create_pick_ticket(items, ship_to_address, pick_ticket_options)
puts "Created Pick Tickets: #{response}\n\n"

puts "Canceling Pick Ticket..."
response = client.cancel_pick_ticket(pick_ticket_id)
puts "Canceled Pick Ticket: #{response}\n\n"

puts "Getting Pick Tickets by number..."
response = client.pick_ticket_by_number(pick_ticket_id)
puts "Completed Pick Tickets by number: #{response}\n\n"

puts "Creating Receiving Ticket..."
response = client.create_receiving_ticket(items, receiving_ticket_options)
puts "Created Receiving Ticket: #{response}"