require "endpoint_base/sinatra/base"

class HighriseEndpoint < EndpointBase::Sinatra::Base
  set :logging, true

  Highrise::Base.site = ENV["HIGHRISE_SITE_URL"]
  Highrise::Base.user = ENV["HIGHRISE_API_TOKEN"]
  Highrise::Base.format = :xml

  # Adds new customer to Highrise from spree hub.
  #
  # Spree Hub ==> Highrise
  #  firstname | firstname
  #  lastname  | lastname
  #  |
  #  |
  #  |
  #  |
  #  |
  #  |

  post "/add_customer" do
    @person = Highrise::Person.new(
      name: "#{@payload[:customer][:firstname]} #{@payload[:customer][:lastname]}",
      contact_data: {
        email_addresses: [
          {
            address: @payload[:customer][:email],
            location: 'Work'
          }
        ]

      }
    )

    if @person.save
      jbuilder :add_customer_success
    else
      jbuilder :add_customer_failure
    end
  end

  post "/update_customer" do

  end

  post "/add_order" do

  end

  post "/update_order" do

  end

  post "/add_product" do

  end

  post "/update_product" do

  end

  post "/add_shipment" do

  end

  post "/update_shipment" do

  end
end
