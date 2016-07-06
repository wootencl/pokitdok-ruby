require 'oauth2'

class OAuthApplicationClient < OAuth2::Client
  attr_accessor :token

  def initialize(client_id, client_secret, site, token_url, code)
    @client_id = client_id
    @client_secret = client_secret
    @site = site
    @token_url = token_url
    @code = code
    @token = nil
    @api_client = nil

    if code
    #   authorization grant flow
    else
      @api_client = super(@client_id, @client_secret, site: @site, token_url: @token_url)
      if @token.nil?
        @token = @api_client.client_credentials.fetch_token(headers: { 'Authorization' => 'Basic' })
      end
    end
  end

  def get(path, opts, &block)
    if isAccessTokenExpired?
      print 'EXPIRED!'
    end
    @token.get(path, opts = opts, &block)
  end

  def put(path, opts, &block)
    if isAccessTokenExpired?
      print 'EXPIRED!'
    end
    @token.put(path, opts = opts, &block)
  end

  def post(path, opts, &block)
    if isAccessTokenExpired?
      print 'EXPIRED!'
    end
    @token.post(path, opts = opts, &block)
  end

  def delete(path, opts, &block)
    if isAccessTokenExpired?
      print 'EXPIRED!'
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