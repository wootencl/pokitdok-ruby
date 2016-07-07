require 'oauth2'

class OAuthApplicationClient < OAuth2::Client
  attr_accessor :token

  def initialize(client_id, client_secret, site, token_url, code)
    @client_id = client_id
    @client_secret = client_secret
    @site = site
    @token_url = token_url
    @auth_code = code
    @token = nil
    @api_client = nil

    super(@client_id, @client_secret, site: @site, token_url: @token_url)
  end

  def get(path, opts, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    @token.get(path, opts = opts, &block)
  end

  def put(path, opts = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    opts.merger({ headers: { :'Content-Type' => 'application/json'}})
    @token.put(path, opts = opts, &block)
  end

  def post(path, opts = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    opts.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.post(path, opts, &block)
  end

  def delete(path, opts = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    opts.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.delete(path, opts = opts, &block)
  end

  def fetch_access_token()
    @token = self.client_credentials.get_token(headers: { 'Authorization' => 'Basic' })
  end

  def isAccessTokenExpired?
    if !@token.is_a?(OAuth2::AccessToken)
      return true
    end
    @token.expired?
  end
end