require "builder"
require 'xmlsimple'

module Rex11
  class Client
    include ActiveMerchant::PostsData

    TEST_URL = "http://sync.rex11.com/ws/v2staging/publicapiws.asmx"
    LIVE_URL = "http://sync.rex11.com/ws/v2prod/publicapiws.asmx"

    attr_accessor :auth_token

    def initialize(username, password, testing = true, options = {})
      raise "Username is required" unless username
      raise "Password is required" unless password

      default_options = {
          :logging => true,
      }

      options = default_options.update(options)

      @username = username
      @password = password

      @logging = options[:logging]
      @url = testing ? TEST_URL : LIVE_URL
      @options = options
    end

    def authenticate
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml.SOAP :Body do
          xml.AuthenticationTokenGet(:xmlns => "http://rex11.com/webmethods/") do |xml|
            xml.WebAddress(@url)
            xml.UserName(@username)
            xml.Password(@password)
          end
        end
      end
      parse_authenticate_response(commit(xml.target!))
    end

    def add_styles_for_item(item)
      require_auth_token
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml.SOAP :Body do
          xml.StyleMasterProductAdd(:xmlns => "http://rex11.com/webmethods/") do |xml|
            xml.AuthenticationString(@auth_token)
            xml.products do |xml|
              xml.StyleMasterProduct do |xml|
                xml.Style(item[:style], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Description(item[:description], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Color(item[:color], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Size(item[:size], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.UPC(item[:upc], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Price(item[:price], :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
              end
            end
          end
        end
      end
      parse_add_style_response(commit(xml.target!))
    end

    def create_pick_tickets_for_items(items, ship_to_address, pick_ticket_options)
      require_auth_token
      xml_request = Builder::XmlMarkup.new
      xml_request.instruct!
      xml_request.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.SOAP :Body do
          xml_request.PickTicketAdd(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.newPickTicket(:xmlns => "http://rex11.com/swpublicapi/PickTicket.xsd") do |xml_request|
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
      xml_request.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.SOAP :Body do
          xml_request.GetPickTicketObjectByBarCode(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.ptbarcode(pick_ticket_number)
          end
        end
      end
      parse_get_pick_ticket_object_by_bar_code(commit(xml_request.target!))
    end

    def create_receiving_ticket_for_items(items, supplier, receiving_ticket_options)
      require_auth_token
      xml_request = Builder::XmlMarkup.new
      xml_request.instruct!
      xml_request.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml_request.SOAP :Body do
          xml_request.GetPickTicketObjectByBarCode(:xmlns => "http://rex11.com/webmethods/") do |xml_request|
            xml_request.AuthenticationString(@auth_token)
            xml_request.ptbarcode(pick_ticket_number)
          end
        end
      end
      parse_receiving_ticket_add_response(xml_request.target!)
    end

    private
    def commit(request)
      ssl_post(@url, request)
    end

    def require_auth_token
      raise "Authentication required for api call" unless @auth_token
    end

    def parse_authenticate_response(xml_response)
      response = XmlSimple.xml_in(xml_response)

      if @auth_token = response["content"]
        true
      else
        raise "Failed Authentication due invalid username, password, or endpoint"
      end
    end

    def parse_add_style_response(xml_response)
      error_string = ""
      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      notifications = response["Body"]["StyleMasterProductAddResponse"]["StyleMasterProductAddResult"]["Notifications"]["Notification"]
      notifications.each do |notification|
        if notification["ErrorCode"] != "0"
          error_string += "Error " + notification["ErrorCode"] + ": " + notification["Message"] + ". "
        end
      end

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_pick_ticket_add_response(xml_response)
      error_string = ""
      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      notifications = response["Body"]["PickTicketAddResponse"]["PickTicketAddResult"]["Notifications"]["Notification"]
      notifications.each do |notification|
        if notification["ErrorCode"] != "0"
          error_string += "Error " + notification["ErrorCode"] + ": " + notification["Message"] + ". "
        end
      end

      if error_string.empty?
        true
      else
        raise error_string
      end
    end

    def parse_get_pick_ticket_object_by_bar_code(xml_response)
      error_string = ""
      return_hash = {}

      response = XmlSimple.xml_in(xml_response, :ForceArray => ["Notification"])
      notifications_block = response["Body"]["GetPickTicketObjectByBarCodeResponse"]["GetPickTicketObjectByBarCodeResult"]["Notifications"]
      if notifications_block.empty?
        #no errors
        pick_ticket_hash = response["Body"]["GetPickTicketObjectByBarCodeResponse"]["GetPickTicketObjectByBarCodeResult"]["PickTicket"]
        return_hash.merge!({
                               :pick_ticket_number => pick_ticket_hash["PickTicketNumber"]["content"],
                               :pick_ticket_status  => pick_ticket_hash["ShipmentStatus"]["content"],
                               :tracking_number => pick_ticket_hash["TrackingNumber"]["content"],
                               :shipping_charge => pick_ticket_hash["FreightCharge"]["content"]
                           })
      else
        #errors
        notifications_block["Notification"].each do |notification|
          if notification["ErrorCode"] != "0"
            error_string += "Error " + notification["ErrorCode"] + ": " + notification["Message"] + ". "
          end
        end
      end

      if error_string.empty?
        return_hash
      else
        raise error_string
      end
    end
  end
end
