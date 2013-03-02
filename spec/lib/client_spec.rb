require 'spec_helper'

describe Rex11::Client do
  before do
    @client = Rex11::Client.new("the_username", "the_password", "the_web_address")
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
          {:upc => "the_upc1", :quantity => 1},
          {:upc => "the_upc2", :quantity => 2}
      ]

      @ship_to_address = {:first_name => "the_ship_to_first_name",
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

  context "pick_ticket_by_number" do
    before do
      @pick_ticket_number = "the_pick_ticket_number"
      @client.auth_token = "4vxVebc3D1zwsXjH9fkFpgpOhewauJbVu25WXjQ1gOo="
    end

    it "should require_auth_token" do
      @client.should_receive(:commit).and_return(xml_fixture("get_pick_ticket_object_by_bar_code_response_success"))
      @client.should_receive(:require_auth_token)
      @client.pick_ticket_by_number(@pick_ticket_number)
    end

    context "request" do
      it "should form correct request" do
        @client.should_receive(:commit).with(squeeze_xml(xml_fixture("get_pick_ticket_object_by_bar_code_request"))).and_return(xml_fixture("get_pick_ticket_object_by_bar_code_response_success"))
        @client.pick_ticket_by_number(@pick_ticket_number)
      end
    end

    context "response" do
      context "when success" do
        it "should return hash" do
          @client.should_receive(:commit).and_return(xml_fixture("get_pick_ticket_object_by_bar_code_response_success"))
          @client.pick_ticket_by_number(@pick_ticket_number).should == {
              :pick_ticket_number => "the_pick_ticket_number",
              :pick_ticket_status => "the_pick_ticket_status",
              :tracking_number => "the_tracking_number",
              :shipping_charge => nil
          }

        end
      end

      context "when error" do
        it "should raise error" do
          @client.should_receive(:commit).and_return(xml_fixture("get_pick_ticket_object_by_bar_code_response_error"))
          lambda {
            @client.pick_ticket_by_number(@pick_ticket_number)
          }.should raise_error("Error 83: BarCode doesn't exist. ")
        end
      end
    end
  end

  context "create_receiving_ticket_for_items" do
    before do
      @items = [{:style => "the_style1",
                 :upc => "the_upc1",
                 :size => "the_size1",
                 :color => "the_color1",
                 :description => "the_description1",
                 :quantity => "the_quantity1",
                 :comments => "the_comments1",
                 :shipment_type => "the_shipment_type1"
                },
                {:style => "the_style2",
                 :upc => "the_upc2",
                 :size => "the_size2",
                 :color => "the_color2",
                 :description => "the_description2",
                 :quantity => "the_quantity2",
                 :comments => "the_comments2",
                 :shipment_type => "the_shipment_type2"
                }
      ]

      @receiving_ticket_options = {
          :warehouse => "the_warehouse",
          :carrier => "the_carrier",
          :memo => "the_memo",
          :supplier => {:company_name => "the_supplier_company_name",
               :address1 => "the_supplier_address1",
               :address2 => "the_supplier_address2",
               :city => "the_supplier_city",
               :state => "the_supplier_state",
               :zip => "the_supplier_zip",
               :country => "the_supplier_country",
               :phone => "the_supplier_phone",
               :email => "the_supplier_email"
              }
      }

      @client.auth_token = "4vxVebc3D1zwsXjH9fkFpgpOhewauJbVu25WXjQ1gOo="
    end

    it "should require_auth_token" do
      @client.should_receive(:commit).and_return(xml_fixture("receiving_ticket_add_response_success"))
      @client.should_receive(:require_auth_token)
      @client.create_receiving_ticket_for_items(@items, @receiving_ticket_options)
    end

    context "request" do
      it "should form correct request" do
        @client.should_receive(:commit).with(squeeze_xml(xml_fixture("receiving_ticket_add_request"))).and_return(xml_fixture("receiving_ticket_add_response_success"))
        @client.create_receiving_ticket_for_items(@items, @receiving_ticket_options)
      end
    end

    context "response" do
      context "when success" do
        it "should return the receiving ticket id" do
          @client.should_receive(:commit).and_return(xml_fixture("receiving_ticket_add_response_success"))
          @client.create_receiving_ticket_for_items(@items, @receiving_ticket_options).should == "the_receiving_ticket_id"
        end
      end

      context "when error" do
        it "should raise error" do
          @client.should_receive(:commit).and_return(xml_fixture("receiving_ticket_add_response_error"))
          lambda {
            @client.create_receiving_ticket_for_items(@items, @receiving_ticket_options)
          }.should raise_error("Error 12: ReceivingTicket/SupplierDetails/Country is not valid. Error 32: ReceivingTicket/Shipmentitemslist/Size[item 1] is not valid. ")
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