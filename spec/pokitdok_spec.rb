# encoding: UTF-8

require 'spec_helper'

CLIENT_ID = 'jSoRZy4iLIIxj23vWb5x'
CLIENT_SECRET = '6eZuizJqfz0ffhY9Gh8mrPvpjyd7D25mrqgq8XrC'
POKITDOK_TEST_URL = 'http://localhost:5002/api/v3'

describe PokitDok do
  describe 'Basic functionality' do
    it 'should point at the correct PokitDok API URL' do
      @pd = PokitDok.new(CLIENT_ID, CLIENT_SECRET)
      @pd.api_url.must_equal 'https://platform.pokitdok.com/api/v3'
    end
  end

  describe 'Authenticated functions' do
    before do
      PokitDok.any_instance.stubs(:api_url).returns(POKITDOK_TEST_URL)
      @pokitdok = PokitDok.new(CLIENT_ID, CLIENT_SECRET)
    end

    it 'should instantiate with a client id and client secret' do
      refute_nil(@pokitdok, 'New PokitDok was nil.')
    end

    it 'should authenticate on a new connection' do
      refute_nil @pokitdok.client
    end

    it 'should refresh the connection if it expires' do
      skip 'Not implemented'
    end

    describe 'Activities endpoint' do
      it 'should expose the activities endpoint' do
        skip 'Not implemented'
      end
    end

    describe 'Cash Prices endpoint' do
      it 'should expose the cash prices endpoint' do
        skip 'Not implemented'
      end
    end

    describe 'Eligibility endpoint' do
      it 'should expose the eligibility endpoint' do
        eligibility_data = { payer_id: 'MOCKPAYER',
                             member_id: 'W34237875729',
                             provider_id: '1467560003',
                             provider_name: 'AYA-AY',
                             provider_first_name: 'JEROME',
                             provider_type: '1',
                             member_name: 'JOHN DOE',
                             member_birth_date: '05/21/1975',
                             service_types: ['Health Benefit Plan Coverage'] }
                             
        @eligibility = @pokitdok.eligibility(eligibility_data)
        refute_nil @eligibility
        refute_nil @eligibility['data']
      end
    end

    describe 'Enrollment endpoint' do
      it 'should expose the enrollment endpoint' do
        skip 'Not implemented'
      end
    end

    describe 'Files endpoint' do
      it 'should expose the files endpoint' do
        skip 'Not implemented'
      end
    end

    describe 'Insurance Prices endpoint' do
      it 'should expose the insurance prices endpoint' do
        skip 'Not implemented'
      end
    end

    describe 'Payers endpoint' do
      it 'should expose the payers endpoint' do
        skip 'Not implemented'
      end
    end
  end
end
