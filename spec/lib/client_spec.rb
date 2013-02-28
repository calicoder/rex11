require 'spec_helper'

describe Rex11::Client do
  before do
    @client = Rex11::Client.new("the_username", "the_password")
  end

  context "authenticate" do
    context "request" do
      it "should form correct request" do
        @client.should_receive(:commit).with(squeeze_xml(xml_fixture("authentication_token_get_request"))).and_return(xml_fixture("authentication_token_get_response_success"))
        @client.authenticate
      end
    end

    context "response" do
      context "success" do
        before do
          @client.should_receive(:commit).and_return(xml_fixture("authentication_token_get_response_success"))
        end

        it "should set auth_token" do
          @client.authenticate
          @client.auth_token.should == "4vxVebc3D1zwsXjH9fkFpgpOhewauJbVu25WXjQ1gOo="
        end

        it "should return true" do
          @client.authenticate.should be_true
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
  end

  context "add_styles_for_item" do
    before do
      @item = {
          :style => "the_style",
          :upc => "the_upc",
          :size => "the_size",
          :price => "the_price",
          :color => "the_color",
          :description => "the_description"
      }

      @client.auth_token = "4vxVebc3D1zwsXjH9fkFpgpOhewauJbVu25WXjQ1gOo="
    end

    it "should require_auth_token" do
      @client.should_receive(:commit).and_return(xml_fixture("style_master_product_add_response_success"))
      @client.should_receive(:require_auth_token)
      @client.add_styles_for_item(@item)
    end

    context "request" do
      it "should form correct request" do
        @client.should_receive(:commit).with(squeeze_xml(xml_fixture("style_master_product_add_request"))).and_return(xml_fixture("style_master_product_add_response_success"))
        @client.add_styles_for_item(@item)
      end
    end

    context "response" do
      context "when success" do
        it "should return true" do
          @client.should_receive(:commit).and_return(xml_fixture("style_master_product_add_response_success"))
          @client.add_styles_for_item(@item).should == true
        end
      end

      context "when error" do
        it "should raise error" do
          @client.should_receive(:commit).and_return(xml_fixture("style_master_product_add_response_error"))
          lambda {
            @client.add_styles_for_item(@item)
          }.should raise_error("Error 31: COLOR[item 1] is not valid. Error 43: PRICE[item 1] is not valid. Error 31: COLOR[item 2] is not valid. Error 31: COLOR[item 4] is not valid. ")
        end
      end
    end
  end

  context "create_pick_tickets_for_items" do
    before do
      @items = [
          { :upc => "the_upc1", :quantity => 1 },
          { :upc => "the_upc2", :quantity => 2 }
      ]

      @ship_to_address = { :first_name => "the_ship_to_first_name",
                           :last_name => "the_ship_to_last_name",
                           :company_name => "the_ship_to_company_name",
                           :address1 => "the_ship_to_address1",
                           :address2 => "the_ship_to_address2",
                           :city => "the_ship_to_city",
                           :state => "the_ship_to_state",
                           :zip => "the_ship_to_zip",
                           :country => "the_ship_to_country",
                           :phone => "the_ship_to_phone",
                           :email => "the_ship_to_email"
      }

      @pick_ticket_options = {
          :pick_ticket_number => "23022012012557",
          :warehouse => "the_warehouse",
          :payment_terms => "NET",
          :use_ups_account => "1",
          :ship_via_account_number => "1AB345",
          :ship_via => "UPS",
          :ship_service => "UPS GROUND - Commercial",
          :billing_option => "PREPAID",
          :bill_to_address => {
              :first_name => "the_bill_to_first_name",
              :last_name => "the_bill_to_last_name",
              :company_name => "the_bill_to_company_name",
              :address1 => "the_bill_to_address1",
              :address2 => "the_bill_to_address2",
              :city => "the_bill_to_city",
              :state => "the_bill_to_state",
              :zip => "the_bill_to_zip",
              :country => "the_bill_to_country",
              :phone => "the_bill_to_phone",
              :email => "the_bill_to_email"
          }
      }

      @client.auth_token = "4vxVebc3D1zwsXjH9fkFpgpOhewauJbVu25WXjQ1gOo="
    end

    it "should require_auth_token" do
      @client.should_receive(:commit).and_return(xml_fixture("pick_ticket_add_response_success"))
      @client.should_receive(:require_auth_token)
      @client.create_pick_tickets_for_items(@items, @ship_to_address, @pick_ticket_options)
    end

    context "request" do
      it "should form correct request" do
        @client.should_receive(:commit).with(squeeze_xml(xml_fixture("pick_ticket_add_request"))).and_return(xml_fixture("pick_ticket_add_response_success"))
        @client.create_pick_tickets_for_items(@items, @ship_to_address, @pick_ticket_options)
      end
    end

    context "response" do
      context "when success" do
        it "should return true" do
          @client.should_receive(:commit).and_return(xml_fixture("pick_ticket_add_response_success"))
          @client.create_pick_tickets_for_items(@items, @ship_to_address, @pick_ticket_options).should == true
        end
      end

      context "when error" do
        it "should raise error" do
          @client.should_receive(:commit).and_return(xml_fixture("pick_ticket_add_response_error"))
          lambda {
            @client.create_pick_tickets_for_items(@items, @ship_to_address, @pick_ticket_options)
          }.should raise_error("Error 56: PickTicket/ShipVia is not valid. Error 61: PickTicket/ShipService is not valid. Error 10: State for ShipToAddress is required for USA. ")
        end
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