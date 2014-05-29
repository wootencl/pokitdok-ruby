# encoding: UTF-8

require 'spec_helper'

CLIENT_ID = 'umGGEcetubysDyPohc3h'
CLIENT_SECRET = 'MlOFhf4XwDrNVL7vyjxTSjUNlKUO7jLgkjh7JDCS'
POKITDOK_TEST_URL = 'http://localhost:5002/api/v3'

def check_meta_and_data(result)
  refute_empty result['meta']
  refute_empty result['data']
end

describe PokitDok do
  describe 'Basic functionality' do
    it 'should point at the correct PokitDok API URL' do
      VCR.use_cassette('basic') do
        @pd = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET)
        @pd.api_url.must_equal 'https://platform.pokitdok.com/api/v3'
      end
    end
  end

  describe 'Authenticated functions' do
    before do
      PokitDok::PokitDok.any_instance.stubs(:api_url)
        .returns(POKITDOK_TEST_URL)
      @pokitdok = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET)
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
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.activities
      end

      it 'should expose the activities endpoint' do
        @activities = @pokitdok.activities['data']
        refute_empty @activities
      end
    end

    describe 'Cash Prices endpoint' do
      it 'is unimplemented' do
        proc { @pokitdok.cash_prices }.must_raise(NotImplementedError)
      end
    end

    describe 'Claims endpoint' do
      it 'should expose the claims endpoint' do
        query = JSON.parse(IO.read('spec/fixtures/claim.json'))
        @claim = @pokitdok.claims(query)['data']
        refute_empty @claim
        @claim['units_of_work'].must_equal 1
        assert_nil @claim['errors']
      end
    end

    describe 'Claims Status endpoint' do
      it 'is unimplemented' do
        proc { @pokitdok.claim_status }.must_raise(NotImplementedError)
      end
    end

    describe 'Deductible endpoint' do
      it 'is unimplemented' do
        proc { @pokitdok.deductible }.must_raise(NotImplementedError)
      end
    end

    describe 'Eligibility endpoint' do
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.eligibility
      end

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

        VCR.use_cassette('eligibility') do
          @eligibility = @pokitdok.eligibility(eligibility_data)['data']

          refute_nil @eligibility
          assert_nil @eligibility['errors']
        end
      end
    end

    describe 'Enrollment endpoint' do
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.enrollment
      end

      it 'should expose the enrollment endpoint' do
        query = JSON.parse(IO.read('spec/fixtures/enrollment.json'))

        @enrollment = @pokitdok.enrollment(query)['data']
        @enrollment['units_of_work'].must_equal 1
        assert_nil @enrollment['errors']
      end
    end

    describe 'Files endpoint' do
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.files
      end

      it 'should expose the files endpoint' do
        query = {}

        @response = @pokitdok.files(query)
        print @response
        refute_nil @response
      end
    end

    describe 'Insurance Prices endpoint' do
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.insurance_prices
      end

      it 'should expose the insurance prices endpoint' do
        query = { zip_code: '54321', cpt_code: '12345' }

        @prices = @pokitdok.insurance_prices(query)['data']
        refute_empty @prices
      end
    end

    describe 'Payers endpoint' do
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.payers
      end

      it 'should expose the payers endpoint' do
        @payers = @pokitdok.payers(state: 'CA')['data']
        refute_nil @payers
        @payers.size.must_equal 20
      end
    end

    describe 'Providers endpoint' do
      it 'should return a meta hash and a data hash' do
        check_meta_and_data @pokitdok.providers(state: 'CA')
      end

      it 'should expose the providers endpoint' do
        query = { state: 'CA' }

        @providers = @pokitdok.providers(query)['data']
        refute_nil @providers
        @providers.size.must_equal 20
      end
    end
  end
end
