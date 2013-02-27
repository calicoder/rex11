require 'spec_helper'

describe Rex11::Client do
  before do
    @client = Rex11::Client.new("the_username", "the_password")
  end

  context "authenticate" do
    context "success" do
      it "should set auth_token" do
        @client.should_receive(:commit).and_return(xml_fixture("authentication_token_get_response_success"))
        @client.authenticate
        @client.auth_token.should == "4vxVebc3D1zwsXjH9fkFpgpOhewauJbVu25WXjQ1gOo="
      end
    end

    context "error" do
      it "should raise error and not set auth_token" do
        @client.should_receive(:commit).and_return(xml_fixture("authentication_token_get_response_error"))

        lambda {
          @client.authenticate
        }.should raise_error("Failed Authentication due invalid username, password, or endpoint")
        @client.auth_token.should be_nil
      end
    end
  end

  context "add_style" do
    before do
      @client.auth_token = "something"
    end

    it "should require_auth_token" do
      @client.should_receive(:commit).and_return(xml_fixture("style_master_product_add_response_success"))
      @client.should_receive(:require_auth_token)
      @client.add_style("the_style", "the_upc", "the_size", "the_price", "the_color")
    end

    context "success" do
      it "should return true" do
        @client.should_receive(:commit).and_return(xml_fixture("style_master_product_add_response_success"))
        @client.add_style("the_style", "the_upc", "the_size", "the_price", "the_color").should == true
      end
    end

    context "error" do
      it "should raise error" do
        @client.should_receive(:commit).and_return(xml_fixture("style_master_product_add_response_error"))
        lambda {
          @client.add_style("the_style", "the_upc", "the_size", "the_price", "the_color")
        }.should raise_error("Error 31: COLOR[item 1] is not valid. Error 43: PRICE[item 1] is not valid. Error 31: COLOR[item 2] is not valid. Error 31: COLOR[item 4] is not valid. ")
      end
    end
  end

  context "require_auth_token" do
    it "should raise error if auth_token is not set" do
      lambda {
        @client.send("require_auth_token")
      }.should raise_error("Authentication required for api call")
    end

    it "should not raise error if auth_token is set" do
      @client.auth_token = "something"
      lambda {
        @client.send("require_auth_token")
      }.should_not raise_error
    end
  end
end