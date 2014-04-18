# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'oauth2'

# PokitDok API client implementation for Ruby.
class PokitDok
  POKITDOK_URL_BASE = 'https://platform.pokitdok.com' # :nodoc:

  attr_reader :client # :nodoc:
  attr_reader :token  # :nodoc:

  # Connect to the PokitDok API with the specified Client ID and Client Secret.
  #
  # +client_id+     your client ID, provided by PokitDok
  #
  # +client_secret+ your client secret, provided by PokitDok
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

  ##
  # Refreshes the client token associated with this PokitDok connection
  #
  # FIXME: automatic refresh on expiration
  def refresh_token
    @token = client.client_credentials.get_token(
      headers: { 'Authorization' => 'Basic' })
  end

  # Invokes the activities endpoint, with an optional Hash of parameters.
  def activities(params = {})
    response = @token.get('activities', params: params)
    JSON.parse(response.body)
  end

  # Invokes the cash prices endpoint, with an optional Hash of parameters.
  def cash_prices(params = {})
    response = @token.get('prices/cash', params: params)
    JSON.parse(response.body)
  end

  # Invokes the eligibility endpoint, with an optional Hash of parameters.
  def eligibility(params = {})
    response = @token.post('eligibility/', body: params.to_json) do |request|
      request.headers['Content-Type'] = 'application/json'
    end
    JSON.parse(response.body)
  end

  # Invokes the enrollment endpoint, with an optional Hash of parameters.
  def enrollment(params = {})
    response = @token.post('enrollment/', body: params.to_json) do |request|
      request.headers['Content-Type'] = 'application/json'
    end
    JSON.parse(response.body)
  end

  # Invokes the files endpoint, with an optional Hash of parameters.
  def files(params = {})
    response = @token.files('files', params: params)
    JSON.parse(response.body)
  end

  # Invokes the insurance prices endpoint, with an optional Hash of parameters.
  def insurance_prices(params = {})
    response = @token.get('prices/insurance', params: params)
    JSON.parse(response.body)
  end

  # Invokes the payers endpoint, with an optional Hash of parameters.
  def payers(params = {})
    response = @token.get('/payers', params: params)
    JSON.parse(response.body)
  end
end
