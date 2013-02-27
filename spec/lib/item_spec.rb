require 'spec_helper'

describe Rex11::Item do
  before do
    @style = "the_style"
    @upc = "the_upc"
    @price = "the_price"
    @color = "the_color"
    @description = "the_description"
    @item = Rex11::Item.new(@style, @upc, @size, @price, @color, @description)
  end

  context "instance attributes" do
    %w{style upc size price color description}.each do |attribute|
      it "should set style" do
        @item.send(attribute).should == instance_variable_get("@" + attribute)
      end
    end
  end
end