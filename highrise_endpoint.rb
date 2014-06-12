Bundler.require(:default)
require "endpoint_base/sinatra/base"
Dotenv.load

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
          jbuilder :add_order_success
        else
          jbuilder :add_order_failure
        end
      end
    end

    post "/add_product" do
      set_highrise_configs(@payload)

    end

    post "/update_product" do
      set_highrise_configs(@payload)

    end

    post "/add_shipment" do
      set_highrise_configs(@payload)

    end

    post "/update_shipment" do
      set_highrise_configs(@payload)

    end
  end
end
