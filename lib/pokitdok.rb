# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'oauth2'

# PokitDok API client implementation for Ruby.
class PokitDok
  POKITDOK_URL_BASE = 'http://localhost:5002'

  attr_reader :client
  attr_reader :token

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret

    @client = OAuth2::Client.new(@client_id, @client_secret,
                                 site: api_url, token_url: '/oauth2/token')
    refresh_token
  end

  def api_url
    POKITDOK_URL_BASE + '/api/v3'
  end

  def refresh_token
    @token = client.client_credentials.get_token(
      headers: { 'Authorization' => 'Basic' })
  end

  def activities(params = {})
    response = @token.get('activities', params: params)
    JSON.parse(response.body)
  end

  def cash_prices(params = {})
    response = @token.get('prices/cash', params: params)
    JSON.parse(response.body)
  end

  def eligibility(params = {})
    response = @token.post('eligibility/', body: params.to_json) do |request|
      request.headers['Content-Type'] = 'application/json'
    end
    JSON.parse(response.body)
  end

  def enrollment(params = {})
    response = @token.post('enrollment/', body: params.to_json) do |request|
      request.headers['Content-Type'] = 'application/json'
    end
    JSON.parse(response.body)
  end

  def files(params = {})
    response = @token.files('files', params: params)
    JSON.parse(response.body)
  end

  def insurance_prices(params = {})
    response = @token.get('prices/insurance', params: params)
    JSON.parse(response.body)
  end

  def payers(params = {})
    response = @token.get('/payers', params: params)
    JSON.parse(response.body)
  end
end
