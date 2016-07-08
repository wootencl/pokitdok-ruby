require 'oauth2'

# Constants
REFRESH_TOKEN_DURATION = 55;

class OAuthApplicationClient
  attr_accessor :token, :user_agent

  def initialize(client_id, client_secret, site, token_url, code, user_agent)
    @client_id = client_id
    @client_secret = client_secret
    @site = site
    @token_url = token_url
    @auth_code = code
    @user_agent = user_agent

    @api_client = OAuth2::Client.new(@client_id, @client_secret, site: @api_url, token_url: '/oauth2/token')
    @token = fetch_access_token()
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
    @token.put(path, params: params, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def post_request(path, params = {}, &block)
    if isAccessTokenExpired?
      fetch_access_token()
    end
    headers.merge({ headers: { :'Content-Type' => 'application/json'}})
    @token.post(path, params: params, headers: headers({:'Content-Type' => 'application/json'}), &block)
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
    @token.delete(path, params: params, headers: headers({:'Content-Type' => 'application/json'}), &block)
  end

  def fetch_access_token()
    @api_client.client_credentials.get_token(headers: { 'Authorization' => 'Basic' })
  end

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

  private :fetch_access_token, :headers, :isAccessTokenExpired?
end