require 'spec_helper'

describe Rex11::Address do
  before do
    @first_name = "the_first_name"
    @last_name = "the_last_name"
    @company_name = "the_company_name"
    @address1 = "the_address1"
    @address2 = "the_address2"
    @city = "the_city"
    @state = "the_state"
    @zip = "the_zip"
    @country = "the_country"
    @non_us_region = "the_non_us_region"
    @phone = "the_phone"
    @email = "the_email"

    @address = Rex11::Address.new(@first_name, @last_name, @company_name, @address1, @address2, @city, @state, @zip, @country, @non_us_region, @phone, @email)
  end

  context "instance attributes" do
    %w{first_name last_name company_name address1 address2 city state zip country non_us_region phone email}.each do |attribute|
      it "should set #{attribute}" do
        @address.send(attribute).should == instance_variable_get("@" + attribute)
      end
    end
  end
end