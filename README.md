pokitdok-ruby
=============

PokitDok Platform API Client for Ruby

## Installation
    gem install --local pokitdok-ruby-0.2.1.gem

## Resources
* [Read the PokitDok API docs][apidocs]
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]

[apidocs]: https://platform.pokitdok.com/dashboard#/documentation
[code]: https://github.com/PokitDokInc/pokitdok-ruby
[issues]: https://github.com/PokitDokInc/pokitdok-ruby/issues

## Usage Example
```ruby
2.1.1 :001 > require 'pokitdok'
true
2.1.1 :002 > pd = PokitDok::PokitDok.new(your_client_id, your_client_secret)
#<PokitDok:0x007fd59126d3b0 ...
2.1.1 :003 > params = { payer_id: "MOCKPAYER",
                        member_id: "W34237875729",
                        provider_id: "1467560003",
                        provider_name: "AYA-AY",
                        provider_first_name: "JEROME",
                        provider_type: "1",
                        member_name: "JOHN DOE",
                        member_birth_date: "05/21/1975",
                        service_types: ["Health Benefit Plan Coverage"] }
{
               :payer_id => "MOCKPAYER",
              :member_id => "W34237875729",
            :provider_id => "1467560003",
          :provider_name => "AYA-AY",
    :provider_first_name => "JEROME",
          :provider_type => "1",
            :member_name => "JOHN DOE",
      :member_birth_date => "05/21/1975",
          :service_types => [
        [0] "Health Benefit Plan Coverage"
    ]
}
2.1.1 :004 > pd.eligibility(params)
{
    "meta" => {
        "rate_limit_amount" => 3,
         "rate_limit_reset" => 1397773751,
                "test_mode" => true,
          "processing_time" => 220,
           "rate_limit_cap" => 1000,
        "credits_remaining" => -2,
           "credits_billed" => 1
    },
    "data" => {
                "provider_id" => "1467560003",
                  "client_id" => "9sKnBkx5MkRG3qWk3ZBj",
                 "payer_name" => "MOCK PAYER INC",
             "correlation_id" => "752a1f85-e950-4a2a-bae4-138d1f6f65da",
          "member_first_name" => "JOHN",
                "member_name" => "JOHN DOE",
              "valid_request" => true,
                  "update_dt" => "Thu Apr 17 21:46:13 2014",
                 "subscriber" => {
            "first_name" => "JOHN",
             "last_name" => "DOE",
               "address" => {
                       "city" => "SPARTANBURG",
                       "line" => "123 MAIN ST",
                "postal_code" => "29307",
                      "state" => "SC"
                      	...
```

## Supported Ruby Versions
This library aims to support and is tested against these Ruby versions:

* Ruby 1.9.3-p545
* Ruby 2.0.0-p451
* Ruby 2.1.1

You may have luck with other interpreters - let us know how it goes.

## License
Copyright (c) 2014 PokitDok Inc. See [LICENSE][] for details.

[license]: LICENSE.txt
