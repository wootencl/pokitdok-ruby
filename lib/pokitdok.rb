require 'rubygems'
require 'bundler/setup'

require 'oauth2'

class PokitDok
  attr_reader :access_token

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret

    @access_token = OAuth2::Client.new(@client_id, @client_secret,
                                       site: api_url)
  end

  def api_url
    'https://platform.pokitdok.com/api'
  end
end
