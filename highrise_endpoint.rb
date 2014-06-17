Bundler.require(:default)
require "endpoint_base/sinatra"
Dotenv.load

# Sets the Highrise credentials based on what is provided
def set_highrise_configs(payload)
  Highrise::Base.site = payload[:parameters]["highrise.site_url"]
  Highrise::Base.user = payload[:parameters]["highrise.api_token"]
end

module HighriseEndpoint
  class Application < EndpointBase::Sinatra::Base
    set :logging, true

    # Adds new customer to Highrise from spree hub.
    post "/add_customer" do
      set_highrise_configs(@payload)

      people = Highrise::Person.search(customer_id: @payload[:customer][:id])

      if people.length > 0
        @person = people.first
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload, person: JSON.parse(@person.to_json)).build

        if @person.field("Customer ID") == @payload[:customer][:id]
          @person.load(structure)
        else
          @person = Highrise::Person.new(structure)
        end

        if @person.save
          jbuilder :update_customer_success
        else
          jbuilder :update_customer_failure
        end
      else
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload).build
        @person = Highrise::Person.new(structure)

        if @person.save
          jbuilder :add_customer_success
        else
          jbuilder :add_customer_failure
        end
      end
    end

    post "/update_customer" do
      set_highrise_configs(@payload)

      people = Highrise::Person.search(customer_id: @payload[:customer][:id])
      if people.length > 0
        @person = people.first
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload, person: JSON.parse(@person.to_json)).build

        if @person.field("Customer ID") == @payload[:customer][:id]
          @person.load(structure)
        else
          @person = Highrise::Person.new(structure)
        end

        if @person.save
          jbuilder :update_customer_success
        else
          jbuilder :update_customer_failure
        end
      else
        structure = HighriseEndpoint::PersonBlueprint.new(payload: @payload).build
        @person = Highrise::Person.new(structure)

        if @person.save
          jbuilder :add_customer_success
        else
          jbuilder :add_customer_failure
        end
      end
    end

    post "/add_order" do
      set_highrise_configs(@payload)

      deals = Highrise::Deal.all
      deals = deals.map{ |deal|
         deal if deal.name == "Order ##{@payload[:order][:id]}"
      }.compact

      person = Highrise::Person.search(@payload[:order][:billing_address]).first

      if deals.length > 0
        @deal = deals.first
        structure = HighriseEndpoint::DealBlueprint.new(payload: @payload, deal: JSON.parse(@deal.to_json)).build

        if @deal.name == "Order ##{@payload[:order][:id]}"
          @deal.load(structure)
        else
          @deal = Highrise::Deal.new(structure)
        end

        if @deal.save
          jbuilder :update_order_success
        else
          jbuilder :update_order_failure
        end
      else
        structure = HighriseEndpoint::DealBlueprint.new(payload: @payload).build
        @deal = Highrise::Deal.new(structure)

        if @deal.save
          @note = Highrise::Note.create(body: @payload[:order][:line_items].to_json, subject_id: @deal.id, subject_type: "Deal")

          jbuilder :add_order_success
        else
          jbuilder :add_order_failure
        end
      end
    end

    post "/update_order" do
      set_highrise_configs(@payload)

      deals = Highrise::Deal.all
      deals = deals.map{ |deal|
         deal if deal.name == "Order ##{@payload[:order][:id]}"
      }.compact

      person = Highrise::Person.search(@payload[:order][:billing_address]).first

      if deals.length > 0
        @deal = deals.first
        structure = HighriseEndpoint::DealBlueprint.new(payload: @payload, deal: JSON.parse(@deal.to_json)).build

        if @deal.name == "Order ##{@payload[:order][:id]}"
          @deal.load(structure)
        else
          @deal = Highrise::Deal.new(structure)
        end

        if @deal.save
          jbuilder :update_order_success
        else
          jbuilder :update_order_failure
        end
      else
        structure = HighriseEndpoint::DealBlueprint.new(payload: @payload).build
        @deal = Highrise::Deal.new(structure)

        if @deal.save
          @note = Highrise::Note.create(body: @payload[:order][:line_items].to_json, subject_id: @deal.id, subject_type: "Deal")

          jbuilder :add_order_success
        else
          jbuilder :add_order_failure
        end
      end
    end

    post "/add_shipment" do
      set_highrise_configs(@payload)

      @shipment = @payload[:shipment]

      deals = Highrise::Deal.all
      deals = deals.map{ |deal|
        deal if deal.name == "Order ##{@shipment[:order_id]}"
      }.compact

      @deal = deals.first

      if @deal
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
#{@shipment[:items]}

Shipped On: #{@shipment[:shipped_at] ? @shipment[:shipped_at] : "Not yet shipped."}
SHIPMENT_BODY

        @note = Highrise::Note.create(body: shipment_body, subject_id: @deal.id, subject_type: "Deal")

        if @note.save
          jbuilder :add_shipment_success
        else
          jbuilder :add_shipment_failure
        end
      end
    end

    post "/update_shipment" do
      set_highrise_configs(@payload)

      @shipment = @payload[:shipment]

      deals = Highrise::Deal.all
      deals = deals.map{ |deal|
        deal if deal.name == "Order ##{@shipment[:order_id]}"
      }.compact

      @deal = deals.first

      if @deal
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
#{@shipment[:items]}

Shipped On: #{@shipment[:shipped_at] ? @shipment[:shipped_at] : "Not yet shipped."}
SHIPMENT_BODY

        @note = Highrise::Note.create(body: shipment_body, subject_id: @deal.id, subject_type: "Deal")

        if @note.save
          jbuilder :update_shipment_success
        else
          jbuilder :update_shipment_failure
        end
      end
    end
  end
end
