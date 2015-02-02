# -*- coding: utf-8 -*-
#
# Copyright (C) 2014-2015, All Rights Reserved, PokitDok, Inc.
# https://www.pokitdok.com
#
# Please see the LICENSE.txt file for more information.
# All other rights reserved.
#

require 'rubygems'
require 'bundler/setup'
require 'base64'
require 'json'
require 'oauth2'
require 'net/http/post/multipart'

module PokitDok
  # PokitDok API client implementation for Ruby.
  class PokitDok
    POKITDOK_URL_BASE = 'https://platform.pokitdok.com' # :nodoc:

    attr_reader :client # :nodoc:
    attr_reader :token  # :nodoc:
    attr_reader :api_url
    attr_reader :version

    # Connect to the PokitDok API with the specified Client ID and Client
    # Secret.
    #
    # +client_id+     your client ID, provided by PokitDok
    #
    # +client_secret+ your client secret, provided by PokitDok
    #
    def initialize(client_id, client_secret, version='v4')
      @client_id = client_id
      @client_secret = client_secret
      @version = version

      @api_url = "#{url_base}/api/#{version}"

      @client = OAuth2::Client.new(@client_id, @client_secret,
                                   site: @api_url, token_url: '/oauth2/token')
      refresh_token
    end

    def url_base
      POKITDOK_URL_BASE
    end

    def user_agent
      "pokitdok-ruby 0.8 #{RUBY_DESCRIPTION}"
    end

    # returns a standard set of headers to be passed along with all requests
    def headers
      { 'User-Agent' => user_agent }
    end

    # Refreshes the client token associated with this PokitDok connection
    #
    # FIXME: automatic refresh on expiration
    #
    def refresh_token
      @token = client.client_credentials.get_token(
        headers: { 'Authorization' => 'Basic' })
    end

    # Invokes the appointments endpoint, to query for open appointment slots
    # (using pd_provider_uuid and location) or booked appointments (using
    # patient_uuid).
    #
    # +params+ an optional Hash of parameters
    #
    def activities(params = {})
      get('activities/', params)
    end

    # Invokes the appointments endpoint to query for an open appointment
    # slot or a booked appointment given a specific pd_appointment_uuid,
    # the PokitDok unique appointment identifier.
    #
    # +params+ an optional Hash of parameters
    #
    def appointment(params = {})
      @appointment_id = params.delete :appointment_id

      get_one('schedule/appointmenttypes/', @appointment_id, params)
    end

    # Invokes the activities endpoint.
    #
    # +params+ an optional Hash of parameters
    #
    def appointments(params = {})
      get('schedule/appointments/', params)
    end

    # Invokes the appointment_types endpoint, to get information on a specific
    # appointment type.
    #
    # +params+ an optional Hash of parameters
    #
    def appointment_type(params = {})
      appointment_type = params.delete :appointment_type

      response =
      @token.get("schedule/appointmenttypes/#{appointment_type}") do |request|
        request.params = params
      end
      JSON.parse(response.body)
    end

    # Invokes the appointment_types endpoint.
    #
    # +params+ an optional hash of parameters
    #
    def appointment_types(params = {})
      get('schedule/appointmenttypes/', params)
    end

    # Invokes the authorizations endpoint.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def authorizations(params = {})
      post('authorizations/', params)
    end

    # Books an appointment.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def book_appointment(params = {})
      @appointment_id = params.delete :appointment_id
      
      put_one('schedule/appointments/', @appointment_id, params)
    end

    # Invokes the cash prices endpoint.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def cash_prices(params = {})
      get('prices/cash', params)
    end

    # Cancels the specified appointment.
    #
    # +params+ an optional Hash of parameters
    #
    def cancel_appointment(params={})
      @appointment_id = params.delete :appointment_id

      delete_one("schedule/appointments", @appointment_id, params)
    end

    # Invokes the claims endpoint.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def claims(params = {})
      post('claims/', params)
    end

    # Invokes the claims status endpoint.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def claims_status(params = {})
      post('claims/status', params)
    end

    # Invokes the eligibility endpoint.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def eligibility(params = {})
      post('eligibility/', params)
    end

    # Invokes the enrollment endpoint.
    #
    # +params+ an optional hash of parameters that will be sent in the POST body
    #
    def enrollment(params = {})
      post('enrollment/', params)
    end

    # Uploads an EDI file to the files endpoint.
    # Uses the multipart-post gem, since oauth2 doesn't support multipart.
    #
    # +trading_partner_id+ the trading partner to transmit to
    # +filename+ the path to the file to transmit
    #
    def files(trading_partner_id, filename)
      url = URI.parse(@api_url + '/files/')

      File.open(filename) do |f|
        req = Net::HTTP::Post::Multipart.new url.path,
          'file' => UploadIO.new(f, 'application/EDI-X12', filename),
          'trading_partner_id' => trading_partner_id
        req['Authorization'] = "Bearer #{@token.token}"
        req['User-Agent'] = user_agent

        @response = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
      end

      JSON.parse(@response.body)
    end

    # Invokes the insurance prices endpoint.
    #
    # +params+ an optional hash of parameters
    #
    def insurance_prices(params = {})
      get('prices/insurance', params)
    end

    # Invokes the schedule/appointments endpoint.
    #
    # +params+ an optional hash of parameters
    #
    def open_appointment_slots(params = {})
      get('schedule/appointments', params)
    end

    # Invokes the payers endpoint.
    #
    # +params+ an optional hash of parameters
    #
    def payers(params = {})
      get('payers/', params)
    end

    # Invokes the plans endpoint.
    #
    # +params+ an optional Hash of parameters
    #
    def plans(params = {})
      get('plans/', params)
    end

    # Invokes the providers endpoint.
    #
    # +params+ an optional Hash of parameters
    #
    def providers(params = {})
      response = @token.get('providers/') do |request|
        request.params = params
      end
      JSON.parse(response.body)
    end

    # Invokes the referrals endpoint.
    #
    # +params+ an optional Hash of parameters
    #
    def referrals(params = {})
      post('referrals/', params)
    end

    # Invokes the schedulers endpoint.
    #
    # +params an optional Hash of parameters
    def schedulers(params = {})
      get('schedule/schedulers/', params)
    end

    # Invokes the schedulers endpoint, to get information about a specific
    # scheduler.
    #
    # +params+ an optional Hash of parameters
    #
    def scheduler(params = {})
      scheduler_id = params.delete :scheduler_id

      response =
      @token.get("schedule/schedulers/#{scheduler_id}") do |request|
        request.params = params
      end
      JSON.parse(response.body)
    end

    # Invokes the slots endpoint.
    #
    # +params+ an optional Hash of parameters
    def slots(params = {})

    end

    # Invokes the trading partners endpoint.
    #
    # +params+ an optional Hash of parameters
    #
    def trading_partners(params = {})
      trading_partner_id = params.delete :trading_partner_id

      response =
      @token.get("tradingpartners/#{trading_partner_id}") do |request|
        request.params = params
      end
      JSON.parse(response.body)
    end

    # Updates the specified appointment.
    #
    # +params+ an optional Hash of parameters
    #
    def update_appointment(params={})
      @appointment_id = params.delete :appointment_id

      put_one("schedule/appointments", @appointment_id, params)
    end    

    private
      def get(endpoint, params = {})
        response = @token.get(endpoint, headers: headers, params: params)

        JSON.parse(response.body)
      end

      def get_one(endpoint, id, params = {})
        response = @token.get("#{endpoint}/#{id}", headers: headers,
                                 body: params.to_json) do |request|
          request.headers['Content-Type'] = 'application/json'
        end

        JSON.parse(response.body)
      end

      def post(endpoint, params = {})
        response = @token.post(endpoint, headers: headers,
                               body: params.to_json) do |request|
          request.headers['Content-Type'] = 'application/json'
        end

        JSON.parse(response.body)
      end

      def put_one(endpoint, id, params = {})
        response = @token.put("#{endpoint}/#{id}", headers: headers,
                                 body: params.to_json) do |request|
          request.headers['Content-Type'] = 'application/json'
        end

        JSON.parse(response.body)
      end

      def delete_one(endpoint, id, params = {})
        response = @token.delete("#{endpoint}/#{id}", headers: headers,
                                 body: params.to_json) do |request|
          request.headers['Content-Type'] = 'application/json'
        end

        JSON.parse(response.body)
      end

  end
end
