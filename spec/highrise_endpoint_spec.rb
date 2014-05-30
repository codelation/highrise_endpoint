require 'spec_helper'

describe HighriseEndpoint do
  def add_customer
    {
      request_id: Faker::Number.number(25),
      customer: {
        id:        Faker::Number.number(10),
        firstname: Faker::Name.first_name,
        lastname:  Faker::Name.last_name,
        email:     Faker::Internet.email,
        shipping_address: {
          address1: Faker::Address.street_address,
          address2: Faker::Address.secondary_address,
          zipcode:  Faker::Address.zip_code,
          city:     Faker::Address.city,
          state:    Faker::Address.state,
          country:  Faker::Address.country,
          phone:    Faker::Number.number(25)
        },
        billing_address: {
          address1: Faker::Address.street_address,
          address2: Faker::Address.secondary_address,
          zipcode:  Faker::Address.zip_code,
          city:     Faker::Address.city,
          state:    Faker::Address.state,
          country:  Faker::Address.country,
          phone:    Faker::Number.number(25)
        }
      }
    }
  end


  # Note: Should we be using context here to check if a customer exists already before adding a new one?  This might take care of our issue where we keep getting the same customer created repeatedly.
  describe "| POST -> '/add_customer'" do
    context "with an existing person" do
      before(:all) do
        @add_customer    = add_customer
        @customer        = @add_customer[:customer]
        @billing_address = @customer[:billing_address]

        Highrise::Person.new(
          name: "#{@customer[:firstname]} #{@customer[:lastname]}",
          contact_data: {
            email_addresses: [
              {
                address: @customer[:email],
                location: 'Work'
              }
            ],
            addresses: [
              {
                # Need to figure out what all of the information is to be added in the address
                address: {
                  city:     @billing_address[:city],
                  country:  @billing_address[:country],
                  location: 'Work',
                  state:    @billing_address[:state],
                  street:   @billing_address[:address1],
                  zip:      @billing_address[:zipcode]
                }
              }
            ],
            phone_numbers: [
              phone_number: {
                location: 'Work',
                number:   @billing_address[:phone]
              }
            ],
            customer_id: @customer[:id]
          }
        ).save
      end

      before(:each) do
        VCR.use_cassette(:add_existing_person) do
          # change something to make sure it's updating it :)
          @add_customer[:customer][:firstname] = "Matthew"

          # we need to reassign these variables since we updated stuff
          @customer = @add_customer[:customer]
          @billing_address = @customer[:billing_address]

          post '/add_customer', @add_customer.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should update information on Highrise" do
        VCR.use_cassette(:retrieve_updated_person) do

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

      it "should return a nice summary" do
        @response_body[:summary].should eql "Customer was added to Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @add_customer[:request_id]
      end
    end

    context "without an existing person" do
      before(:all) do
        VCR.use_cassette(:add_new_person) do
          @add_customer    = add_customer
          @customer        = @add_customer[:customer]
          @billing_address = @customer[:billing_address]

          post '/add_customer', @add_customer.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should add information to Highrise" do
        VCR.use_cassette(:retrieve_created_person) do

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

      it "should return a nice summary" do
        @response_body[:summary].should eql "Customer was added to Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @add_customer[:request_id]
      end
    end
  end



  # test for /add_product webhook
  #
  # TODO: determine what values should be added to highrise and what
  # values need to be tested to verify the change is accurate.
  # describe "| POST -> '/add_product'" do
  #   before(:each) do
  #     VCR.use_cassette(:add_product) do
  #       post '/add_product', add_product.to_json, auth
  #     end
  #
  #     @response_body = JSON.parse(last_response.body).with_indifferent_access
  #   end
  #
  #   it "should return 200" do
  #     last_response.status.should eql 200
  #   end
  #
  #   # verifies product was added to highrise.
  #   #
  #   # Note: I don't really like this part.  We've been trying to decide what needs to be kept of the massive data in the
  #   # add_product json file, but I'm not sure if this is what they're going to need.  The product will need to be linked with a
  #   # deal (known as an order in spree hub), but this doesn't test for whether the product is linked to the deal.
  #   it "should add information to Highrise" do
  #     VCR.use_cassette(:retrieve_product) do
  #       product = add_product[:product]
  #
  #       Products = Highrise::Note.search(
  #         productid:  product[:id],
  #         name:       product[:name],
  #         productsku: product[:sku],
  #         price:      product[:price]
  #       )
  #
  #       products.length.should eql 1
  #     end
  #
  #     it "should return the webhook request_id" do
  #       @response_body[:request_id].should eql add_product[:request_id]
  #     end
  #
  #     it "should return a nice summary" do
  #       @response_body[:summary].should eql "Product was added to Highrise deal note."
  #     end
  #   end
  # end
  #
  # describe "| POST -> /add_order" do
  #   before(:each) do
  #     VCR.use_cassette(:add_order) do
  #       post '/add_order', add_customer.to_json, auth
  #     end
  #     it "should add information to Highrise" do
  #       VCR.use_cassette(:retrieve_person) do
  #         order = add_order[:order]
  #
  #         deals = Highrise::Deal.search(
  #           value:      order[:id],
  #           created_at: order[:placed_on],
  #           currency:   order[:currency],
  #           firstname:  order[:billing_address][:firstname],
  #           lastname:   order[:billing_address][:lastname],
  #           price:      order[:totals][:order]
  #         )
  #
  #         deals.length.should eql 1
  #
  #         it "should return a nice summary" do
  #           @response_body[:summary].should eql "Order was added to Highrise"
  #         end
  #
  #         it "should return the webhook request_id" do
  #           @response_body[:request_id].should eql add_order[:request_id]
  #         end
  #       end
  #     end
  #   end
  # end
  #
  # describe "| POST -> '/add_shipment" do
  #   before(:each) do
  #     VCR.use_cassette(:add_person) do
  #       post "/add_shipment", add_shipment.to_json, auth
  #     end
  #   end
  #
  #   it "should add information to Highrise" do
  #     VCR.use_cassette(:retrieve_person) do
  #       shipment         = add_shipment[:shipment]
  #       item             = add_shipment[:item]
  #       shipping_address = add_shipment[:shipping_address]
  #
  #       # Retrieving the deal with the spree-order id because that is what's
  #       # held within the shipment.
  #       # Uncertain when the deal that has this order-id will be created.
  #       deal             = Highrise::Deal.search(
  #         value: shipment[:order_id]
  #       )
  #
  #       # Need to think about what fields to test for and what to inclue in the implementation.
  #       # Also need to figure out whether the 'subject-id' field is what is needed to look up
  #       # the deal that this note is associated with.
  #       # Even though the body of the field is (probably) temporary, it still lets us test a couple of fields
  #       shipments = Highrise::Note.search(
  #         subject_id:   deal[:id],
  #         subject_type: 'Deal',
  #         created_at:   deal[:shipped_at],
  #         body:         "#{item[:quantity]} #{pluralize(item[:quantity], "item")} shipped to #{shipping_address[:firstname]} #{shipping_address[:lastname]}"
  #       )
  #       shipments.length.should eql 1
  #     end
  #   end
  #
  #   it "should return a nice summary" do
  #     @response_body[:summary].should eql "Shipment was added to Highrise"
  #   end
  #
  #   it "should return the webhook request_id" do
  #     @response_body[:request_id].should eql add_shipment[:request_id]
  #   end
  # end
end

