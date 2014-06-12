require "spec_helper"

describe HighriseEndpoint::Application do
  describe "| POST -> '/update_order'" do
    context "with an existing order" do
      before(:each) do
        VCR.use_cassette(:update_existing_deal) do
          @existing_order = HighriseEndpoint::Requests.new(:order, "existing_update").to_hash
          set_highrise_parameters(@existing_order)

          @structure = HighriseEndpoint::DealBlueprint.new(payload: @existing_order).build

          Highrise::Deal.new(@structure).save

          # Change something to make sure it's updating it :)
          @existing_order[:order][:totals][:order] = 100000

          # Reassign these variables since we updated stuff
          @order = @existing_order[:order]

          post "/add_order", @existing_order.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should update deal on Highrise" do
        VCR.use_cassette(:retrieve_updated_update_order) do

          deals = Highrise::Deal.all
          deals = deals.map{ |deal|
             deal if deal.name == "Order ##{@order[:id]}" && deal.price == 1000.00
          }.compact

          deals.length.should eql 1
        end
      end

      it "should return a nice summary" do
        @response_body[:summary].should eql "Deal was updated on Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @existing_order[:request_id]
      end
    end

    context "without an existing deal" do
      before(:all) do
        VCR.use_cassette(:update_new_deal) do
          @new_order = HighriseEndpoint::Requests.new(:order, "new_update").to_hash
          set_highrise_parameters(@new_order)

          @order = @new_order[:order]

          post "/add_order", @new_order.to_json, auth
        end

        @response_body = JSON.parse(last_response.body).with_indifferent_access
      end

      it "should return 200" do
        last_response.status.should eql 200
      end

      it "should add deal to Highrise" do
        VCR.use_cassette(:retrieve_created_update_order) do

          deals = Highrise::Deal.all
          deals = deals.map{ |deal|
             deal if deal.name == "Order ##{@order[:id]}"
          }.compact

          deals.length.should eql 1
        end
      end

      it "should return a nice summary" do
        @response_body[:summary].should eql "Deal was added to Highrise."
      end

      it "should return the webhook request_id" do
        @response_body[:request_id].should eql @new_order[:request_id]
      end
    end
  end
end
