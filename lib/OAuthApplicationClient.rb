require 'oauth2'

class OAuthApplicationClient
  attr_accessor :token, :user_agent

  # TODO: Figure out how to pass in a refreshToken method to be used by the authorization grant flow

  def initialize(client_id, client_secret, site, token_url, redirect_uri, scope, code, token, user_agent)
    @client_id = client_id
    @client_secret = client_secret
    @site = site
    @token_url = token_url
    @redirect_uri = redirect_uri
    @scope = scope
    @code = code
    @user_agent = user_agent
    @token  = token

    @api_client = OAuth2::Client.new(@client_id, @client_secret, site: @api_url, token_url: '/oauth2/token')
    if @token.nil?
      fetch_access_token(@code)
    end
  end

  def get_request(path, params, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    @token.get(path, params: params, headers: headers, &block)
  end

  def put_request(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    headers.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.put(path, body: params.to_json, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def post_request(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    headers.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.post(path, body: params.to_json, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def post_file(endpoint, file=nil, params={})
    if isAccessTokenExpired?
      fetch_access_token()
    end
    url = URI.parse(@site + endpoint)

    File.open(file) do |f|
      additional_params = params.merge({'file' => UploadIO.new(f, 'application/EDI-X12', file)})
      req = Net::HTTP::Post::Multipart.new(url.path, additional_params)

      req['Authorization'] = "Bearer #{self.token.token}"
      req['User-Agent'] = @user_agent

      @response = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
      JSON.parse(@response.body)
    end
  end

  def delete_request(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    @token.delete(path, body: params.to_json, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def authorization_url()
    if @redirect_uri.nil? || @scope.nil?
      raise 'A redirect_uri and scope must be specified when the client is instantiated in order to get a working authorization URL'
    end
    @api_client.auth_code.authorize_url(redirect_uri: @redirect_uri, scope: @scope)
  end

  def fetch_access_token(code = nil)
    if code
      # Currently non functioning as our OAuth2 authorization_code grant type is not implemented on the server
      params =  {
        headers: { 'Authorization' => 'Basic' },
        scope: @scope,
        redirect_uri: @redirect_uri
      }
      @token = @api_client.auth_code.get_token(code, params)
    else
      @token = @api_client.client_credentials.get_token(headers: { 'Authorization' => 'Basic' })
    end
  end

  ### PRIVATE METHODS ###

  # Returns a standard set of headers to be passed along with all requests
  def headers(additional_headers = {})
    { 'User-Agent' => @user_agent }.merge(additional_headers)
  end

  def isAccessTokenExpired?
    if !@token.is_a?(OAuth2::AccessToken)
      return true
    end
    @token.expired?
  end

  private :headers, :isAccessTokenExpired?
end