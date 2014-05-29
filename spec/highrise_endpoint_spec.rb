require 'spec_helper'

describe HighriseEndpoint do
  let(:add_customer) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_customer.json")).with_indifferent_access }
  
  describe "| POST -> '/add_customer'" do
    it "should return 200" do
      VCR.use_cassette(:add_person) do
        post '/add_customer', add_customer.to_json, auth
        last_response.status.should eql 200
      end
    end

    it "should add information to Highrise" do
      VCR.use_cassette(:add_person) do
        post '/add_customer', add_customer.to_json, auth
      end
      VCR.use_cassette(:retrieve_person) do
        customers = Highrise::Person.search(
          email: add_customer[:customer][:email],
          firstname: add_customer[:customer][:firstname],
          lastname: add_customer[:customer][:lastname]
        )
        customers.length.should eql 1
      end
    end

    it "should return a nice summary" do
      VCR.use_cassette(:add_person) do
        post '/add_customer', add_customer.to_json, auth
        response = JSON.parse(last_response.body).with_indifferent_access
        response[:summary].should eql "Customer was added to Highrise as a person."
      end
    end
  
    it "should return the webhook request_id" do
      VCR.use_cassette(:add_person) do
        post '/add_customer', add_customer.to_json, auth
        response = JSON.parse(last_response.body).with_indifferent_access
        response[:request_id].should eql add_customer[:request_id]
      end
    end
  end
end