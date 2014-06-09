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

    end

    post "/update_order" do
      set_highrise_configs(@payload)

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
