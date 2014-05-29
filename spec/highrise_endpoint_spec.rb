require 'spec_helper'

describe HighriseEndpoint do
  let(:add_customer) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_customer.json")).with_indifferent_access }
  let(:add_shipment) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_customer.json")).with_indifferent_access }

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
          country:   billing_address[:country]
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

  describe "| POST -> '/add_shipment" do
    before(:each) do
      VCR.use_cassette(:add_person) do
        post "/add_shipment", add_shipment.to_json, auth
      end

      @response_body = JSON.parse(last_response.body).with_indifferent_access
    end

    it "should return 200" do
      last_response.status.should eql 200
    end

    it "should add information to Highrise" do
      VCR.use_cassette(:retrieve_person) do
        shipment = add_shipment[:shipment]
        item = add_shipment[:item]
        shipping_address = add_shipment[:shipping_address]
        deal = Highrise::Deal.search(
          value: shipment[:order_id] #retrieving the deal's spree-order id
        )

        shipments = Highrise::Note.search(
          subject_id: deal[:id],
          subject_type: 'Deal',
          created_at: deal[:shipped_at],
          body: "#{item[:quantity]} #{pluralize(item[:quantity], "item")} shipped to 
          #{shipping_address[:firstname]} #{shipping_address[:lastname]}"
        )
        shipments.length.should eql 1
      end
    end

    it "should return a nice summary" do
      @response_body[:summary].should eql "Shipment was added to Highrise"
    end

    it "should return the webhook request_id" do
      @response_body[:request_id].should eql add_shipment[:request_id]
    end
  end
end
