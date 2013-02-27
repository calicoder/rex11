require "builder"

module Rex11
  class Client
    include ActiveMerchant::PostsData

    TEST_URL = "http://sync.rex11.com/ws/v2staging/publicapiws.asmx"
    LIVE_URL = "http://sync.rex11.com/ws/v2prod/publicapiws.asmx"

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
      result = xml.SOAP :Envelope, :"xmlns:soap" => "http://schemas.xmlsoap.org/soap/envelope/", :"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance" do
        xml.SOAP :Body do
          xml.AuthenticationTokenGet(:xmlns => "http://rex11.com/webmethods/") { |xml|
            xml.WebAddress(@url)
            xml.UserName(@username)
            xml.Password(@password)
          }
        end
      end
      response = commit(xml)
    end

    def commit(request)
      ssl_post(@url, request)
    end
  end
end
