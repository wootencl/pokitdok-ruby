require 'oauth2'

class OAuthApplicationClient < OAuth2::Client
  attr_accessor :token

  def initialize(client_id, client_secret, site, token_url)
    @client_id = client_id
    @client_secret = client_secret
    @site = site
    @token_url = token_url
    @token = nil

    super(@client_id, @client_secret, site: @site, token_url: @token_url)
  end

  def get(path, opts, &block)
    if isAccessTokenExpired?
      put "EXPIRED!"
    end
    @token.get(path, opts = opts, &block)
  end

  def put(path, opts, &block)
    if isAccessTokenExpired?
      put "EXPIRED!"
    end
    @token.put(path, opts = opts, &block)
  end

  def post(path, opts, &block)
    if isAccessTokenExpired?
      put "EXPIRED!"
    end
    @token.post(path, opts = opts, &block)
  end

  def delete(path, opts, &block)
    if isAccessTokenExpired?
      put "EXPIRED"
    end
    @token.delete(path, opts = opts, &block)
  end

  def isAccessTokenExpired?
    if !@token.is_a?(OAuth2::AccessToken)
      return true
    end
    @token.expired?
  end
end