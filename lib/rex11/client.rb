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
      xml.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", :"xmlns:xsd" => "http://www.w3.org/2001/XMLSchema" do
        xml.SOAP :Body do
          xml.StyleMasterProductAdd(:xmlns => "http://rex11.com/webmethods/") do |xml|
            xml.AuthenticationString(@auth_token)
            xml.products do |xml|
              xml.StyleMasterProduct do |xml|
                xml.Style(item.style, :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Description(item.description, :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Color(item.color, :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Size(item.size, :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.UPC(item.upc, :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
                xml.Price(item.price, :xmlns => "http://rex11.com/swpublicapi/StyleMasterProduct.xsd")
              end
            end
          end
        end
      end
      parse_add_style_response(commit(xml.target!))
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
      @auth_token = response["content"]
      raise "Failed Authentication due invalid username, password, or endpoint" unless @auth_token
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
  end
end
