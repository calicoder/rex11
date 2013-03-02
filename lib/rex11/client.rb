require "builder"
require 'xmlsimple'
require 'net/http'

module Rex11
  class Client

    TEST_HOST = "sync.rex11.com"
    TEST_PATH = "/ws/v2staging/publicapiws.asmx"
    LIVE_HOST = "sync.rex11.com"
    LIVE_PATH = "/ws/v2prod/publicapiws.asmx"

    attr_accessor :auth_token

    def initialize(username, password, web_address, testing = true, options = {})
      raise "Username is required" unless username
      raise "Password is required" unless password

      default_options = {
          :logging => true,
      }

      options = default_options.update(options)

      @username = username
      @password = password
      @web_address = web_address

      @logging = options[:logging]
      @host = testing ? TEST_HOST : LIVE_HOST
      @path = testing ? TEST_PATH : LIVE_PATH
      @options = options
    end

    def authenticate
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.soap :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml.soap :Body do
          xml.AuthenticationTokenGet(:xmlns => "http://rex11.com/webmethods/") do |xml|
            xml.WebAddress(@web_address)
            xml.UserName(@username)
            xml.Password(@password)
          end
        end
      end
      parse_authenticate_response(commit(xml.target!))
    end

    def add_styles_for_item(item)
      require_auth_token
      xml_request = Builder::XmlMarkup.new
      xml_request.instruct!
      xml_request.soap :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.soap :Body do
          xml_request.StyleMasterProductAdd(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.products do |xml_request|
              xml_request.StyleMasterProduct do |xml_request|
                xml_request.Style(item[:style], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml_request.UPC(item[:upc], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml_request.Size(item[:size], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml_request.Color(item[:color], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml_request.Description(item[:description], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml_request.Price(item[:price], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
              end
            end
          end
        end
      end
      parse_add_style_response(commit(xml_request.target!))
    end

    def create_pick_tickets_for_items(items, ship_to_address, pick_ticket_options)
      require_auth_token
      xml_request = Builder::XmlMarkup.new
      xml_request.instruct!
      xml_request.soap :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.soap :Body do
          xml_request.PickTicketAdd(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.PickTicket(:xmlns => "http://rex11.com/swpublicapi/PickTicket.xsd") do |xml_request|
              xml_request.PickTicketNumber(pick_ticket_options[:pick_ticket_number])
              xml_request.WareHouse(pick_ticket_options[:warehouse])
              xml_request.PaymentTerms(pick_ticket_options[:payment_terms])
              xml_request.UseAccountUPS(pick_ticket_options[:use_ups_account])
              xml_request.ShipViaAccountNumber(pick_ticket_options[:ship_via_account_number])
              xml_request.ShipVia(pick_ticket_options[:ship_via])
              xml_request.ShipService(pick_ticket_options[:ship_service])
              xml_request.BillingOption(pick_ticket_options[:billing_option])
              xml_request.BillToAddress do |xml_request|
                xml_request.FirstName(pick_ticket_options[:bill_to_address][:first_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.LastName(pick_ticket_options[:bill_to_address][:last_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.CompanyName(pick_ticket_options[:bill_to_address][:company_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Address1(pick_ticket_options[:bill_to_address][:address1], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Address2(pick_ticket_options[:bill_to_address][:address2], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.City(pick_ticket_options[:bill_to_address][:city], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.State(pick_ticket_options[:bill_to_address][:state], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Zip(pick_ticket_options[:bill_to_address][:zip], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Country(pick_ticket_options[:bill_to_address][:country], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Phone(pick_ticket_options[:bill_to_address][:phone], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Email(pick_ticket_options[:bill_to_address][:email], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
              end
              xml_request.ShipToAddress do |xml_request|
                xml_request.FirstName(ship_to_address[:first_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.LastName(ship_to_address[:last_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.CompanyName(ship_to_address[:company_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Address1(ship_to_address[:address1], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Address2(ship_to_address[:address2], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.City(ship_to_address[:city], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.State(ship_to_address[:state], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Zip(ship_to_address[:zip], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Country(ship_to_address[:country], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Phone(ship_to_address[:phone], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Email(ship_to_address[:email], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
              end

              items.each do |item|
                xml_request.LineItem do |xml_request|
                  xml_request.UPC(item[:upc], :xmlns => "http://rex11.com/swpublicapi/PickTicketDetails.xsd")
                  xml_request.Quantity(item[:quantity], :xmlns => "http://rex11.com/swpublicapi/PickTicketDetails.xsd")
                end
              end
            end
          end
        end
      end
      parse_pick_ticket_add_response(commit(xml_request.target!))
    end

    def pick_ticket_by_number(pick_ticket_number)
      require_auth_token
      xml_request = Builder::XmlMarkup.new
      xml_request.instruct!
      xml_request.soap :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.soap :Body do
          xml_request.GetPickTicketObjectByBarCode(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.ptbarcode(pick_ticket_number)
          end
        end
      end
      parse_get_pick_ticket_object_by_bar_code(commit(xml_request.target!))
    end

    def create_receiving_ticket(items, receiving_ticket_options)
      require_auth_token
      xml_request = Builder::XmlMarkup.new
      xml_request.instruct!
      xml_request.soap :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.soap :Body do
          xml_request.ReceivingTicketAdd(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.receivingTicket(:xmlns => "http://rex11.com/swpublicapi/ReceivingTicket.xsd") do |xml_request|
              items.each do |item|
                xml_request.Shipmentitemslist do |xml_request|
                  xml_request.Style(item[:style], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.UPC(item[:upc], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.Size(item[:size], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.Color(item[:color], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.ProductDescription(item[:description], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.ExpectedQuantity(item[:quantity], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.Comments(item[:comments], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                  xml_request.ShipmentType(item[:shipment_type], :xmlns => "http://rex11.com/swpublicapi/ReceivingTicketItems.xsd")
                end
                xml_request.ShipmentTypelist(item[:shipment_type])
              end
              xml_request.Warehouse(receiving_ticket_options[:warehouse])
              xml_request.Memo(receiving_ticket_options[:memo])
              xml_request.Carrier(receiving_ticket_options[:carrier])
              xml_request.SupplierDetails do |xml_request|
                xml_request.CompanyName(receiving_ticket_options[:supplier][:company_name], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Address1(receiving_ticket_options[:supplier][:address1], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Address2(receiving_ticket_options[:supplier][:address2], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.City(receiving_ticket_options[:supplier][:city], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.State(receiving_ticket_options[:supplier][:state], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Zip(receiving_ticket_options[:supplier][:zip], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Country(receiving_ticket_options[:supplier][:country], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Phone(receiving_ticket_options[:supplier][:phone], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
                xml_request.Email(receiving_ticket_options[:supplier][:email], :xmlns => "http://rex11.com/swpublicapi/CustomerOrder.xsd")
              end

            end
          end
        end
      end
      parse_receiving_ticket_add_response(commit(xml_request.target!))
    end

    private
    def commit(xml_request)
      http = Net::HTTP.new(@host, 80)
      response = http.post(@path, xml_request, {'Content-Type' => 'text/xml'})
      response.body
    end

    def require_auth_token
      raise "Authentication required for api call" unless @auth_token
    end

    def parse_authenticate_response(xml_response)
      response = XmlSimple.xml_in(xml_response, :ForceArray => false)
      response_content = response["Body"]["AuthenticationTokenGetResponse"]["AuthenticationTokenGetResult"]
      if response_content and !response_content.empty?
        @auth_token = response_content
        true
      else
        raise "Failed Authentication due invalid username, password, or endpoint"
      end
    end

    def parse_add_style_response(xml_response)
      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      response_content = response["Body"]["StyleMasterProductAddResponse"]["StyleMasterProductAddResult"]
      error_string = parse_error(response_content)

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_pick_ticket_add_response(xml_response)
      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      response_content = response["Body"]["PickTicketAddResponse"]["PickTicketAddResult"]
      error_string = parse_error(response_content)

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_get_pick_ticket_object_by_bar_code(xml_response)
      return_hash = {}
      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      response_content = response["Body"]["GetPickTicketObjectByBarCodeResponse"]["GetPickTicketObjectByBarCodeResult"]

      pick_ticket_hash = response_content["PickTicket"]
      if pick_ticket_hash and !pick_ticket_hash.empty?
        return_hash.merge!({
                               :pick_ticket_number => pick_ticket_hash["PickTicketNumber"]["content"],
                               :pick_ticket_status => pick_ticket_hash["ShipmentStatus"]["content"],
                               :shipping_charge => pick_ticket_hash["FreightCharge"]["content"]
                           })

        tracking_number = pick_ticket_hash["TrackingNumber"]
        return_hash.merge!({:tracking_number => tracking_number ? tracking_number["content"] : nil})
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_receiving_ticket_add_response(xml_response)
      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      response_content = response["Body"]["ReceivingTicketAddResponse"]["ReceivingTicketAddResult"]

      receiving_ticket_id = response_content["ReceivingTicketId"]
      if receiving_ticket_id and !receiving_ticket_id.empty?
        receiving_ticket_id
      else
        error_string = parse_error(response_content)
        raise error_string unless error_string.empty?
      end
    end

    def parse_error(response_content)
      error_string = ""
      response_content["Notifications"]["Notification"].each do |notification|
        if notification["ErrorCode"] != "0"
          error_string += "Error " + notification["ErrorCode"] + ": " + notification["Message"] + ". "
        end
      end
      error_string
    end
  end
end
