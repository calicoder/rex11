require 'rex11'

def xml_fixture(path) # where path is like 'authentication_token_get_response_success'
  open(File.join(File.dirname(__FILE__), 'fixtures', "#{path}.xml")) { |f| f.read }
end
