require "spec_helper"

describe HighriseEndpoint::Application do
  describe "| POST -> '/update_shipment'" do
    before(:each) do
      VCR.use_cassette(:update_shipment) do
        @new_order = HighriseEndpoint::Requests.new(:order, "for_shipment").to_hash
        set_highrise_parameters(@new_order)

        @structure = HighriseEndpoint::DealBlueprint.new(payload: @new_order).build

        Highrise::Deal.new(@structure).save

        @shipment_request = HighriseEndpoint::Requests.new(:shipment, "update").to_hash
        set_highrise_parameters(@shipment_request)

        @shipment = @shipment_request[:shipment]

        post "/update_shipment", @shipment_request.to_json, auth
      end

      @response_body = JSON.parse(last_response.body).with_indifferent_access
    end

    it "should return 200" do
      last_response.status.should eql 200
    end

    it "should add shipment to deal on Highrise" do
      VCR.use_cassette(:retrieve_updated_shipment_note) do
        address = @shipment[:shipping_address]

        formatted_address = <<-FORMATTED_ADDRESS
#{address[:firstname]} #{address[:lastname]}
#{address[:address1]}
#{address[:address2]}
#{address[:city]}, #{address[:state]}, #{address[:country]} #{address[:zipcode]}
FORMATTED_ADDRESS

        shipment_body = <<-SHIPMENT_BODY
Tracking: #{@shipment[:tracking] ? @shipment[:tracking] : "No tracking code for this shipment."}

Shipped to:
#{formatted_address}

Manifest:
#{line_items_to_string(@shipment[:items])}

Shipped On: #{@shipment[:shipped_at] ? @shipment[:shipped_at] : "Not yet shipped."}
SHIPMENT_BODY

        deals = Highrise::Deal.all
        deals = deals.map{ |deal|
          deal if deal.name == "Order ##{@shipment[:order_id]}" && deal.notes.map{ |note|
            note.body.include?(shipment_body[0..-25]) # remove the last 25 characters because shipping date comes back weird
          }.include?(true)
        }.compact

        deals.length.should eql 1
      end
    end

    it "should create tasks on Highrise" do
      Highrise::Task.all.map{|task| task.body }.should include *@shipment[:highrise_tasks][:person].map{|task| task[:body] }
      Highrise::Task.all.map{|task| task.body }.should include *@shipment[:highrise_tasks][:deal].map{|task| task[:body] }
    end

    it "should return a nice summary" do
      @response_body[:summary].should eql "Shipment info was added to deal: Order ##{@shipment[:order_id]}"
    end

    it "should return the webhook request_id" do
      @response_body[:request_id].should eql @shipment_request[:request_id]
    end
  end
end
