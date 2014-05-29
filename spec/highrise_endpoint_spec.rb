require 'spec_helper'

describe HighriseEndpoint do
  let(:add_customer) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_customer.json")).with_indifferent_access }
  let(:add_order) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_order.json")).with_indifferent_access }
  let(:add_product) { JSON.parse(IO.read("#{File.dirname(__FILE__)}/support/requests/add_product.json")).with_indifferent_access }

  # Note: Should we be using context here to check if a customer exists already before adding a new one?  This might take care of our issue where we keep getting the same customer created repeatedly.
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

  # test for /add_product webhook
  #
  # TODO: determine what values should be added to highrise and what
  # values need to be tested to verify the change is accurate.
  describe "| POST -> '/add_product'" do
    before(:each) do
      VCR.use_cassette(:add_product) do
        post '/add_product', add_product.to_json, auth
      end

      @response_body = JSON.parse(last_response.body).with_indifferent_access
    end

    it "should return 200" do
      last_response.status.should eql 200
    end

    # verifies product was added to highrise.
    #
    # Note: I don't really like this part.  We've been trying to decide what needs to be kept of the massive data in the
    # add_product json file, but I'm not sure if this is what they're going to need.  The product will need to be linked with a
    # deal (known as an order in spree hub), but this doesn't test for whether the product is linked to the deal.
    it "should add information to Highrise" do
      VCR.use_cassette(:retrieve_product) do
        product = add_product[:product]

        Products = Highrise::Note.search(
          productid:  product[:id],
          name:       product[:name],
          productsku: product[:sku],
          price:      product[:price]
        )

        products.length.should eql 1
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql add_product[:request_id]
      end

      it "should return a nice summary" do
        @response_body[:summary].should eql "Product was added to Highrise deal note."
      end
    end
  end

  describe "| POST -> /add_order" do
    before(:each) do
      VCR.use_cassette(:add_order) do
        post '/add_order', add_customer.to_json, auth
      end
      it "should add information to Highrise" do
        VCR.use_cassette(:retrieve_person) do
          order = add_order[:order]

          deals = Highrise::Deal.search(
            value:      order[:id],
            created_at: order[:placed_on],
            currency:   order[:currency],
            firstname:  order[:billing_address][:firstname],
            lastname:   order[:billing_address][:lastname],
            price:      order[:totals][:order]
          )

          deals.length.should eql 1

          it "should return a nice summary" do
            @response_body[:summary].should eql "Order was added to Highrise"
          end

          it "should return the webhook request_id" do
            @response_body[:request_id].should eql add_order[:request_id]
          end
        end
      end
    end
  end

end

