[![Build Status](https://travis-ci.org/pokitdok/pokitdok-ruby.svg?branch=master)](https://travis-ci.org/pokitdok/pokitdok-ruby)
[![Gem Version](https://badge.fury.io/rb/pokitdok-ruby.svg)](http://badge.fury.io/rb/pokitdok-ruby)

pokitdok-ruby
=============

PokitDok Platform API Client for Ruby

## Resources
* [Read the PokitDok API docs][apidocs]
* [View Source on GitHub][code]
* [Report Issues on GitHub][issues]

[apidocs]: https://platform.pokitdok.com/dashboard#/documentation
[code]: https://github.com/PokitDokInc/pokitdok-ruby
[issues]: https://github.com/PokitDokInc/pokitdok-ruby/issues

## Installation
    gem install pokitdok-ruby

## Quick Start
```ruby
require 'pokitdok'
pd = PokitDok::PokitDok.new("your_client_id", "your_client_secret")

# Retrieve provider information by NPI
pd.providers(npi: '1467560003')

# Search providers by name (individuals)
pd.providers(first_name: 'JEROME', last_name: 'AYA-AY')

# Search providers by name (organizations)
pd.providers(name: 'Qliance')

# Search providers by location and/or specialty
pd.providers(zipcode: '29307', radius: '10mi')
pd.providers(zipcode: '29307', radius: '10mi', specialty: 'RHEUMATOLOGY')

# Eligibility
params = { payer_id: "MOCKPAYER",
                        member_id: "W34237875729",
                        provider_id: "1467560003",
                        provider_name: "AYA-AY",
                        provider_first_name: "JEROME",
                        provider_type: "1",
                        member_name: "JOHN DOE",
                        member_birth_date: "05/21/1975",
                        service_types: ["Health Benefit Plan Coverage"] }

pd.eligibility(params)

# Retrieve an index of activities
pd.activities 

# Check on a specific activity
pd.activities(activity_id: '5362b5a064da150ef6f2526c')

# Check on a batch of activities
pd.activities(parent_id: '537cd4b240b35755f5128d5c')

# Upload an EDI file
pd.files('trading_partner_id', 'path/to/a_file.edi')
              
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
