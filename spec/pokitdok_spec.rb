# encoding: UTF-8

require 'spec_helper'

CLIENT_ID = '4nhMZTpLxBxmiocveVb5'
CLIENT_SECRET = 'HUIpG9fFf9Qku9mh0lO50SPSDiju3D9Cjx17oeCN'
POKITDOK_TEST_URL = 'http://localhost:5002/api/v3'

def check_meta_and_data(result)
  refute_empty result['meta']
  refute_empty result['data']
end

describe PokitDok do
  describe 'Authenticated functions' do
    before do
      PokitDok::PokitDok.any_instance.stubs(:api_url)
        .returns(POKITDOK_TEST_URL)
      VCR.use_cassette 'auth' do
        @pokitdok = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET)
      end
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
        VCR.use_cassette 'activities' do
          @activities = @pokitdok.activities
        end

        check_meta_and_data @activities
        refute_empty @activities['data']
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
        VCR.use_cassette 'claims' do
          @claim = @pokitdok.claims(query)
        end

        check_meta_and_data @claim
        refute_empty @claim['data']
        @claim['data']['units_of_work'].must_equal 1
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
      it 'should expose the eligibility endpoint' do
        @eligibility_query = {
          trading_partner_id: 'MOCKPAYER',
          member_id: 'W34237875729',
          provider_id: '1467560003',
          provider_name: 'AYA-AY',
          provider_first_name: 'JEROME',
          provider_type: 'Person',
          member_name: 'JOHN DOE',
          member_birth_date: '05-21-1975',
          service_types: ['Health Benefit Plan Coverage']
        }

        VCR.use_cassette 'eligibility' do
          @eligibility = @pokitdok.eligibility(@eligibility_query)
        end

        check_meta_and_data @eligibility
        refute_nil @eligibility['data']
        assert_nil @eligibility['data']['errors']
      end
    end

    describe 'Enrollment endpoint' do
      it 'should expose the enrollment endpoint' do
        query = JSON.parse(IO.read('spec/fixtures/enrollment.json'))

        VCR.use_cassette 'enrollment' do
          @enrollment = @pokitdok.enrollment(query)
        end

        check_meta_and_data @enrollment
        @enrollment['data']['units_of_work'].must_equal 1
        assert_nil @enrollment['data']['errors']
      end
    end

    describe 'Files endpoint' do
      it 'should expose the files endpoint' do
        VCR.use_cassette 'files' do
          @response = @pokitdok.files('MOCKPAYER',
                                      'spec/fixtures/sample.270')
        end

        check_meta_and_data @response
        refute_nil @response
        # TODO: should get back an activity id
      end
    end

    describe 'Insurance Prices endpoint' do
      it 'should expose the insurance prices endpoint' do
        VCR.use_cassette 'insurance_prices' do
          @prices = @pokitdok.insurance_prices(zip_code: '54321',
                                               cpt_code: '12345')
        end

        check_meta_and_data @prices
        refute_empty @prices['data']
      end
    end

    describe 'Payers endpoint' do
      it 'should expose the payers endpoint' do
        VCR.use_cassette 'payers' do
          @payers = @pokitdok.payers(state: 'CA')
        end

        check_meta_and_data @payers
        refute_nil @payers['data']
        @payers['data'].size.must_equal 36
      end
    end

    describe 'Providers endpoint' do
      it 'should expose the providers endpoint' do
        query = { state: 'CA' }

        VCR.use_cassette 'providers' do
          @providers = @pokitdok.providers(query)
        end

        check_meta_and_data @providers
        refute_nil @providers['data']
        @providers['data'].size.must_equal 20
      end
    end
  end
end
