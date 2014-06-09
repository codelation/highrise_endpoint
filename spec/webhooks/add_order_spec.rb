require "spec_helper"

describe HighriseEndpoint::Application do
  describe "| POST -> '/add_order'" do
    context "with an existing order" do
      before(:each) do
        VCR.use_cassette(:add_existing_order) do
          @existing_order = HighriseEndpoint::Requests.new(:order, "existing").to_hash
          @existing_order[:parameters]["highrise.api_token"] = ENV["HIGHRISE_API_TOKEN"]
          @existing_order[:parameters]["highrise.site_url"] = ENV["HIGHRISE_SITE_URL"]

          @structure    = HighriseEndpoint::DealBlueprint.new(payload: @existing_order).build

          Highrise::Deal.new(@structure).save

          # Change something to make sure it's updating it :)
          @existing_order[:order][:status] = :test

          # Reassign these variables since we updated stuff
          @order = @existing_order[:order]
          @billing_address = @order[:billing_address]

          post "/add_order", @existing_order.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should update information on Highrise" do
        VCR.use_cassette(:retrieve_updated_add_order) do

          orders = Highrise::Deal.search(
            name:   @order[:name],
            status: @order[:status]
          )

          orders.length.should eql 1
        end
      end

      it "should return a nice summary" do
        @response_body[:summary].should eql "Order was updated on Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @existing_order[:request_id]
      end
    end

    # context "without an existing person" do
    #   before(:all) do
    #     VCR.use_cassette(:add_new_person) do
    #       @new_customer    = HighriseEndpoint::Requests.new(:customer, "new").to_hash
    #       @customer        = @new_customer[:customer]
    #       @billing_address = @customer[:billing_address]
    #
    #       post '/add_customer', @new_customer.to_json, auth
    #     end
    #
    #     @response_body = JSON.parse(last_response.body).with_indifferent_access
    #   end
    #
    #   it "should return 200" do
    #     last_response.status.should eql 200
    #   end
    #
    #   it "should add person to Highrise" do
    #     VCR.use_cassette(:retrieve_created_add_person) do
    #
    #       customers = Highrise::Person.search(
    #         email:       @customer[:email],
    #         firstname:   @customer[:firstname],
    #         lastname:    @customer[:lastname],
    #         number:      @billing_address[:phone],
    #         street:      @billing_address[:address1],
    #         city:        @billing_address[:city],
    #         state:       @billing_address[:state],
    #         zip:         @billing_address[:zipcode],
    #         country:     @billing_address[:country],
    #         customer_id: @customer[:id]
    #       )
    #
    #       customers.length.should eql 1
    #     end
    #   end
    #
    #   it "should return a nice summary" do
    #     @response_body[:summary].should eql "Person was added to Highrise."
    #   end
    #
    #   it "should return the webhook request_id" do
    #     @response_body[:request_id].should eql @new_customer[:request_id]
    #   end
    # end
  end
end
