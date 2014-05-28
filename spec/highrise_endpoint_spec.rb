require 'spec_helper'

describe HighriseEndpoint do
  # def parameters
#     { 
#       'quickbooks_access_token' => "123",
#       'quickbooks_access_secret' => "OLDrgtlzvffzyH1hMDtW5PF6exayVlaCDxFjMd0o",
#       'quickbooks_realm' => "1081126165",
#       "quickbooks_deposit_to_account_name" => "Undeposited Funds",
#       "quickbooks_payment_method_name" => [
#         {
#           "master" => "MasterCard",
#           "visa" => "Visa",
#           "american_express" => "AmEx",
#           "discover" => "Discover",
#           "PayPal" => "PayPal"
#         }
#       ],
#       "quickbooks_shipping_item" => "Shipping Charges",
#       "quickbooks_tax_item" => "State Sales Tax-NY",
#       "quickbooks_discount_item" => "Discount",
#       "quickbooks_account_name" => "Inventory Asset",
#       "quickbooks_web_orders_user" => "false"
#     }
#   end
# 
#   describe "quickbooks api errors" do
#     it "" do
#       expect(QBIntegration::Order).to receive(:new).and_raise Quickbooks::ServiceUnavailable
# 
#       post '/add_order', {}.to_json, auth
#       last_response.status.should eql 500
#       expect(json_response[:summary]).to match "Quickbooks API appears to be inaccessible"
#     end
#   end
# 
#   describe "order sync" do
#     let(:message) {
#       {
#         "order" => Factories.order,
#         "parameters" => parameters
#       }.with_indifferent_access
#     }
# 
#     context "new sales receipt" do
#       context "persist new sales receipt" do
#         it "generates a json response with an info notification" do
#           # change order number in case you want to persist a new order
#           message[:order][:number] = "QB-EWEWF-78766"
#           message[:order][:placed_on] = "2014-04-17 17:51:18 -0300"
#           message[:parameters] = Factories.config
# 
#           VCR.use_cassette("sales_receipt/sync_order_sales_receipt_post", match_requests_on: [:body, :method]) do
#             post '/add_order', message.to_json, auth
#             expect(json_response[:summary]).to match "Created Quickbooks Sales Receipt"
#           end
#         end
#       end
# 
#       context "sales receipt already exists" do
#         before do
#           QBIntegration::Service::SalesReceipt.any_instance.stub find_by_order_number: double("SalesOrder", id: 1)
#         end
# 
#         it "500" do
#           post '/add_order', message.to_json, auth
# 
#           last_response.status.should eql 500
#           expect(json_response[:summary]).to match "already has a sales receipt"
#         end
#       end
#     end
# 
#     context "existing sales receipt" do
#       it "updates sales receipt just fine" do
#         pending "replay it, probably failing to some payload change hard to find"
#         VCR.use_cassette("sales_receipt/sync_updated_order_post", match_requests_on: [:body, :method]) do
#           post '/update_order', message.to_json, auth
#           last_response.status.should eql 200
# 
#           expect(json_response[:summary]).to match "Updated Quickbooks Sales Receipt"
#         end
#       end
#     end
# 
#     context "order canceled" do
#       before do
#         message[:order] = Factories.new_credit_memo[:order]
#       end
# 
#       it "generates a json response with an info notification" do
#         VCR.use_cassette("credit_memo/create_from_receipt", match_requests_on: [:body, :method]) do
#           post '/cancel_order', message.to_json, auth
#           last_response.status.should eql 200
# 
#           expect(json_response[:summary]).to match "Created Quickbooks Credit Memo"
#         end
#       end
#     end
#   end
# 
#   describe "return authorizations" do
#     let(:message) do
#       {
#         return: Factories.return_authorization,
#         parameters: parameters
#       }.with_indifferent_access
#     end
# 
#     it "generates a json response with an info notification" do
#       VCR.use_cassette("credit_memo/create_from_return", match_requests_on: [:method, :body]) do
#         post '/add_return', message.to_json, auth
#         last_response.status.should eql 200
# 
#         expect(json_response[:summary]).to match "Created Quickbooks Credit Memo"
#       end
#     end
# 
#     it "returns 500 if order return was not sync yet" do
#       message[:return][:order_id] = "imnotthereatall"
# 
#       VCR.use_cassette("credit_memo/return_authorization_non_sync_order", match_requests_on: [:body, :method]) do
#         post '/add_return', message.to_json, auth
#         last_response.status.should eql 500
#         expect(json_response[:summary]).to match "Received return for order not sync"
#       end
#     end
# 
#     context "update" do
#       it "updates existing return just fine" do
#         VCR.use_cassette("credit_memo/sync_return_authorization_updated", match_requests_on: [:body, :method]) do
#           post '/update_return', message.to_json, auth
# 
#           last_response.status.should eql 200
#           expect(json_response[:summary]).to match "Updated Quickbooks Credit Memo"
#         end
#       end
#     end
#   end
# 
#   context "monitor stock" do
#     let(:parameters) { Factories.config }
# 
#     let(:message) do
#       { "sku" => "4553254352", "parameters" => parameters }
#     end
# 
#     it "returns message with item quantity" do
#       VCR.use_cassette("item/find_item_track_inventory", match_requests_on: [:body, :method]) do
#         post '/get_inventory', message.to_json, auth
#         last_response.status.should eql 200
# 
#         object = json_response[:inventories].first
#         expect(object[:quantity]).to eq 56
#       end
#     end
# 
#     it "returns a inventory collection" do
#       VCR.use_cassette("item/find_by_updated_at", match_requests_on: [:body, :method]) do
#         post '/get_inventory', { parameters: parameters }.to_json, auth
#         last_response.status.should eql 200
# 
#         expect(json_response[:inventories]).to be_present
#         expect(json_response[:parameters]).to have_key 'quickbooks_poll_stock_timestamp'
#       end
#     end
# 
#     it "just 200 if item not found" do
#       message[:sku] = "imreallynothere"
# 
#       VCR.use_cassette("item/item_not_found", match_requests_on: [:body, :method]) do
#         post '/get_inventory', message.to_json, auth
#         last_response.status.should eql 200
#       end
#     end
# 
#     it "just 200 if collection is empty" do
#       QBIntegration::Stock.any_instance.stub items: nil
# 
#       VCR.use_cassette("item/find_by_updated_at", match_requests_on: [:body, :method]) do
#         post '/get_inventory', { parameters: parameters }.to_json, auth
#         last_response.status.should eql 200
#       end
#     end
# 
#     it "friendly message when timestamp is missing" do
#       parameters['quickbooks_poll_stock_timestamp'] = ""
# 
#       post '/get_inventory', { parameters: parameters }.to_json, auth
#       expect(last_response).to_not be_ok
#       expect(json_response[:summary]).to match 'quickbooks_poll_stock_timestamp should be a valid date'
#     end
#   end
# 
#   context "products" do
#     context "account not found" do
#       let(:config) do
#         c = Factories.config
#         c["quickbooks_income_account"] = "Not to be found"
#         c
#       end
# 
#       it "generates an error notification"
#     end
#   end
end