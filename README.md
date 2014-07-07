# Highrise Endpoint
[![Travis Badge](https://travis-ci.org/codelation/highrise_endpoint.svg?branch=master)](https://travis-ci.org/codelation/highrise_endpoint)

This integration is designed to integrate Spree Hub with the [Highrise](https://highrisehq.com) CRM. All transactions related to the Spree storefront will be available for view in Highrise. This is a one-way integration. Data on Highrise will not sync back to the storefront.

## Configuration
The following parameters are required by this integration:

| Key | Value |
| :-- | :---- |
| `highrise.api_token` | Your API token provided by Highrise |
| `highrise.site_url` | Your Highrise site url: https://codelationtesting.highrisehq.com |


## Deployment
To start the server:

```bash
$ rake start RACK_ENV=environment
```

This will automatically attach to port 3000, but if it's on Heroku then it will attach itself to the `PORT` environment variable.

## Functionality
This endpoint implements the following webhook points:

| Object | Webhook | Highrise | Function |
| :----| :-----| :------ | :------- |
| Customer | `/add_customer` | Person | This adds a person in Highrise
| Customer | `/update_customer` | Person | This updates a person in Highrise
| Order | `/add_order` | Deal | This adds a deal in Highrise
| Order | `/update_order` | Deal | This updates a deal in Highrise
| Shipment | `/add_shipment` | Deal.note | This adds a deal note in Highrise
| Shipment | `/update_shipment` | Deal.note | This adds a deal note in Highrise

### Tagging
This endpoint supports tagging of people in Highrise on the `add_customer`, `update_customer`, `add_order`, and `update_order` webhooks.

Example of adding tags to a person in `add_customer` & `update_customer`:
```json
{
  "customer": {
    "id": "a123",
    ...
    "highrise_tags": {
      "person": [
        "Likes T-shirts",
        "Bought a T-shirt"
      ]
    }
  }
}
```

Example of adding tags to the deal's person in `add_order` & `update_order`:
```json
{
  "order": {
    "id": "R154085346",
    ...
    "highrise_tags": {
      "person": [
        "Likes T-shirts",
        "Bought a T-shirt"
      ]
    }
  }
}
```

### Tasks
This endpoint supports creating contextual tasks in Highrise on all webhooks.

Example of adding tags to the contextual person in `add_customer` & `update_customer`:
```json
{
  "customer": {
    "id": "a123",
    ...
    "highrise_tasks": {
      "person": [
        {
          body: "This task will be associated with this person.",
          due: "#{today|tomorrow|this_week|next_week|later|'2007-03-10T15:11:52Z'}",
          assigned_to: HIGHRISE_USER_ID
        }
      ]
    }
  }
}
```

Example of adding contextual tasks to a deal and it's person in `add_order` & `update_order`:
```json
{
  "order": {
    "id": "R154085346",
    ...
    "highrise_tasks": {
      "person": [
        {
          "body": "This task will be associated with this deal's person.",
          "due": "#{today|tomorrow|this_week|next_week|later|'2007-03-10T15:11:52Z'}",
          "assigned_to": HIGHRISE_USER_ID
        }
      ],
      "deal": [
        {
          "body": "This task will be associated with this deal.",
          "due": "#{today|tomorrow|this_week|next_week|later|'2007-03-10T15:11:52Z'}",
          "assigned_to": HIGHRISE_USER_ID
        }
      ]
    }
  }
}
```

Example of adding tags to the deal's person in `add_order` & `update_order`:
```json
{
  "shipment": {
    "id": "12836",
    ...
    "highrise_tasks": {
      "person": [
        {
          "body": "This task will be associated with the person of this shipment's deal.",
          "due": "#{today|tomorrow|this_week|next_week|later|'2007-03-10T15:11:52Z'}",
          "assigned_to": HIGHRISE_USER_ID
        }
      ],
      "deal": [
        {
          "body": "This task will be associated with this shipment's deal.",
          "due": "#{today|tomorrow|this_week|next_week|later|'2007-03-10T15:11:52Z'}",
          "assigned_to": HIGHRISE_USER_ID
        }
      ]
    }
  }
}
```

## Testing & Development
While testing it is important to have two environment variables set. You can either manually set these with `export` or just create a `.env` file in the root of the project with the following format:

```bash
HIGHRISE_API_TOKEN=whateveryourkeymaybe
HIGHRISE_SITE_URL=https://example.highrisehq.com
```

Run all tests with:

```bash
$ rake test
```

The test suite makes heavy use of [VCR](https://github.com/vcr/vcr) to record all Highrise API requests. It also makes use of [Faker](https://github.com/stympy/faker) to generate fake data for webhook requests because Highrise does not like seeing data that it already has, it will give you many errors, and since that data is randomly generated we needed a way to save it so that our request data would match our recorded cassettes. For this we use a custom solution of saving generated fake webhook requests as yml files.

To clean all VCR cassettes and webhook requests:

```bash
$ rake clean
```

After running this running `rake test` will regenerate everything that it needs.

## Gems
The following gems are relied upon for this endpoint.

### General

- [Awesome Print](https://github.com/michaeldv/awesome_print)
- [Dotenv](https://github.com/bkeepers/dotenv)
- [Endpoint::Base](https://github.com/spree/endpoint_base)
- [Foreman](https://github.com/ddollar/foreman)
- [Highrise](https://github.com/tapajos/highrise)
- [Pry](https://github.com/pry/pry)
- [Puma](http://puma.io)
- [Rake](https://github.com/jimweirich/rake)
- [Sinatra](http://www.sinatrarb.com)
- [Tilt](https://github.com/rtomayko/tilt/tree/tilt-1)
- [Tilt::JBuilder](https://github.com/anthonator/tilt-jbuilder)


### Test
- [Faker](https://github.com/stympy/faker)
- [Guard](https://github.com/guard/guard)
- [guard-rspec](https://github.com/guard/guard-rspec)
- [rack-test](https://github.com/brynary/rack-test)
- [Rspec](http://rspec.info)
- [terminal-notifier-guard](https://github.com/Springest/terminal-notifier-guard)
- [vcr](https://github.com/vcr/vcr)
- [webmock](https://github.com/bblimke/webmock)
