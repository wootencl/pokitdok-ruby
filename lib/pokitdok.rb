# -*- coding: utf-8 -*-
#
# Copyright (C) 2014, All Rights Reserved, PokitDok, Inc.
# https://www.pokitdok.com
#
# Please see the LICENSE.txt file for more information.
# All other rights reserved.
#

require 'rubygems'
require 'bundler/setup'
require 'json'
require 'oauth2'
require 'httmultiparty'

module PokitDok
  # PokitDok API client implementation for Ruby.
  class PokitDok
    POKITDOK_URL_BASE = 'https://platform.pokitdok.com' # :nodoc:

    attr_reader :client # :nodoc:
    attr_reader :token  # :nodoc:

    # Connect to the PokitDok API with the specified Client ID and Client
    # Secret.
    #
    # +client_id+     your client ID, provided by PokitDok
    #
    # +client_secret+ your client secret, provided by PokitDok
    #
    def initialize(client_id, client_secret)
      @client_id = client_id
      @client_secret = client_secret

      @client = OAuth2::Client.new(@client_id, @client_secret,
                                   site: api_url, token_url: '/oauth2/token')
      refresh_token
    end

    # Returns the URL used to communicate with the PokitDok API.
    def api_url
      POKITDOK_URL_BASE + '/api/v3'
    end

    # returns a standard set of headers to be passed along with all requests
    def headers
      { 'User-Agent' => "pokitdok-ruby 0.2.1 #{RUBY_DESCRIPTION}" }
    end

    # Refreshes the client token associated with this PokitDok connection
    #
    # FIXME: automatic refresh on expiration
    def refresh_token
      @token = client.client_credentials.get_token(
        headers: { 'Authorization' => 'Basic' })
    end

    # Invokes the activities endpoint, with an optional Hash of parameters.
    def activities(params = {})
      response = @token.get('activities',
                            headers: headers,
                            params: params)
      JSON.parse(response.body)
    end

    # Invokes the cash prices endpoint, with an optional Hash of parameters.
    def cash_prices(params = {})
      fail NotImplementedError, "The PokitDok API does not currently support
        this endpoint."
    end

    # Invokes the claims endpoint, with an optional Hash of parameters.
    def claims(params = {})
      response = @token.post('claims/',
                             headers: headers,
                             body: params.to_json) do |request|
        request.headers['Content-Type'] = 'application/json'
      end
      JSON.parse(response.body)
    end

    # Invokes the claims status endpoint, with an optional Hash of parameters.
    def claim_status(params = {})
      fail NotImplementedError, 'The PokitDok API does not currently support
        this endpoint.'
    end

    # Invokes the deductible endpoint, with an optional Hash of parameters.
    def deductible(params = {})
      fail NotImplementedError, 'The PokitDok API does not currently support
        this endpoint.'
    end

    # Invokes the eligibility endpoint, with an optional Hash of parameters.
    def eligibility(params = {})
      response = @token.post('eligibility/',
                             headers: headers,
                             body: params.to_json) do |request|
        request.headers['Content-Type'] = 'application/json'
      end
      JSON.parse(response.body)
    end

    # Invokes the enrollment endpoint, with an optional Hash of parameters.
    def enrollment(params = {})
      response = @token.post('enrollment/',
                             headers: headers,
                             body: params.to_json) do |request|
        request.headers['Content-Type'] = 'application/json'
      end
      JSON.parse(response.body)
    end

    # Uploads an EDI file to the files endpoint.
    #
    # +trading_partner_id+ the trading partner to transmit to
    #
    # +filename+ the path to the file to transmit
    #
    def files(trading_partner_id, filename)
      response = HTTMultiParty.post(api_url + '/files/',
                      query: {
                        access_token: @token.token,
                        file: File.new(filename),
                        trading_partner_id: trading_partner_id
                      }
      )

      JSON.parse(response.body)
    end

    # Invokes the insurance prices endpoint, with an optional Hash of
    # parameters.
    def insurance_prices(params = {})
      response = @token.get('prices/insurance',
                            headers: headers,
                            params: params)
      JSON.parse(response.body)
    end

    # Invokes the payers endpoint, with an optional Hash of parameters.
    def payers(params = {})
      response = @token.get('payers', headers: headers, params: params)
      JSON.parse(response.body)
    end

    # Invokes the providers endpoint, with an optional Hash of parameters.
    def providers(params = {})
      response = @token.get('providers') do |request|
        request.params = params
      end
      JSON.parse(response.body)
    end
  end
end
