require "spec_helper"

describe HighriseEndpoint::Application do
  describe "| POST -> '/add_customer'" do
    context "with an existing person" do
      before(:each) do
        VCR.use_cassette(:add_existing_person) do
          @existing_customer = HighriseEndpoint::Requests.new(:customer, "existing_add").to_hash
          set_highrise_parameters(@existing_customer)

          @structure    = HighriseEndpoint::PersonBlueprint.new(payload: @existing_customer).build

          Highrise::Person.new(@structure).save

          # Change something to make sure it's updating it :)
          @existing_customer[:customer][:firstname] = "Matthew"

          # Reassign these variables since we updated stuff
          @customer = @existing_customer[:customer]
          @billing_address = @customer[:billing_address]

          post '/add_customer', @existing_customer.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should update information on Highrise" do
        VCR.use_cassette(:retrieve_updated_add_customer) do

          customers = Highrise::Person.search(
            email:       @customer[:email],
            firstname:   @customer[:firstname],
            lastname:    @customer[:lastname],
            number:      @billing_address[:phone],
            street:      @billing_address[:address1],
            city:        @billing_address[:city],
            state:       @billing_address[:state],
            zip:         @billing_address[:zipcode],
            country:     @billing_address[:country],
            customer_id: @customer[:id]
          )

          customers.length.should eql 1
        end
      end

      it "should tag the person on Highrise" do
        VCR.use_cassette(:retrieve_updated_add_customer_with_tags) do

          customers = Highrise::Person.search(
            email:       @customer[:email],
            firstname:   @customer[:firstname],
            lastname:    @customer[:lastname],
            number:      @billing_address[:phone],
            street:      @billing_address[:address1],
            city:        @billing_address[:city],
            state:       @billing_address[:state],
            zip:         @billing_address[:zipcode],
            country:     @billing_address[:country],
            customer_id: @customer[:id]
          )

          customers[0].tags.map{|tag| tag.name }.should include *@customer[:highrise_tags][:person]
        end
      end

      it "should return a nice summary" do
        @response_body[:summary].should eql "Person was updated on Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @existing_customer[:request_id]
      end
    end

    context "without an existing person" do
      before(:all) do
        VCR.use_cassette(:add_new_person) do
          @new_customer    = HighriseEndpoint::Requests.new(:customer, "new_add").to_hash
          set_highrise_parameters(@new_customer)

          @customer        = @new_customer[:customer]
          @billing_address = @customer[:billing_address]

          post '/add_customer', @new_customer.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should add person to Highrise" do
        VCR.use_cassette(:retrieve_created_add_customer) do

          customers = Highrise::Person.search(
            email:       @customer[:email],
            firstname:   @customer[:firstname],
            lastname:    @customer[:lastname],
            number:      @billing_address[:phone],
            street:      @billing_address[:address1],
            city:        @billing_address[:city],
            state:       @billing_address[:state],
            zip:         @billing_address[:zipcode],
            country:     @billing_address[:country],
            customer_id: @customer[:id]
          )

          customers.length.should eql 1
        end
      end

      it "should tag the person on Highrise" do
        VCR.use_cassette(:retrieve_created_add_customer_with_tags) do

          customers = Highrise::Person.search(
            email:       @customer[:email],
            firstname:   @customer[:firstname],
            lastname:    @customer[:lastname],
            number:      @billing_address[:phone],
            street:      @billing_address[:address1],
            city:        @billing_address[:city],
            state:       @billing_address[:state],
            zip:         @billing_address[:zipcode],
            country:     @billing_address[:country],
            customer_id: @customer[:id]
          )

          customers[0].tags.map{|tag| tag.name }.should include *@customer[:highrise_tags][:person]
        end
      end

      it "should return a nice summary" do
        @response_body[:summary].should eql "Person was added to Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @new_customer[:request_id]
      end
    end
  end
end
