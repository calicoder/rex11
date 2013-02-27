require 'spec_helper'

describe Rex11::Client do
  it "should set class variables" do
    client = Rex11::Client.new("the_username", "the_password")
    client.authenticate
  end
end