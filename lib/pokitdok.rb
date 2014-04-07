# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'oauth2'

# PokitDok API client implementation for Ruby.
class PokitDok
  POKITDOK_API_URL = 'https://platform.pokitdok.com/api'

  attr_reader :token

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret

    @token = OAuth2::Client.new(@client_id, @client_secret, site: api_url)
    
  end

  def api_url
    POKITDOK_API_URL
  end
end
