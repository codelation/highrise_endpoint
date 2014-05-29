require 'spec_helper'

describe HighriseEndpoint do
  let(:add_customer) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_customer.json")).with_indifferent_access }

  describe "| POST -> '/add_customer'" do
    before(:each) do
      VCR.use_cassette(:add_person) do
        post '/add_customer', add_customer.to_json, auth
      end

      @response_body = JSON.parse(last_response.body).with_indifferent_access
    end

    it "should return 200" do
      last_response.status.should eql 200
    end

    it "should add information to Highrise" do
      VCR.use_cassette(:retrieve_person) do
        customer        = add_customer[:customer]
        billing_address = customer[:billing_address]

        customers = Highrise::Person.search(
          email:     customer[:email],
          firstname: customer[:firstname],
          lastname:  customer[:lastname],
          number:    billing_address[:phone],
          street:    billing_address[:address1],
          city:      billing_address[:city],
          state:     billing_address[:state],
          zip:       billing_address[:zipcode],
          country:   billing_address[:country],
          value:     customer[:id]
        )
        customers.length.should eql 1
      end
    end

    it "should return a nice summary" do
      @response_body[:summary].should eql "Customer was added to Highrise."
    end

    it "should return the webhook request_id" do
      @response_body[:request_id].should eql add_customer[:request_id]
    end
  end
end
