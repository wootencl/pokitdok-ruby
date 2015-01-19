# encoding: UTF-8

require 'spec_helper'

CLIENT_ID = 'WbkhoNbwuJRWdz0w9Ehl'
CLIENT_SECRET = 'OPA9HSOUMJLYyZrH4VRPZLoL51gGtm7U4OxuYiz6'
POKITDOK_TEST_URL = 'http://localhost:5002'

def check_meta_and_data(result)
  refute_empty result['meta']
  refute_empty result['data']
end

describe PokitDok do
  describe 'Authenticated functions' do
    before do
      PokitDok::PokitDok.any_instance.stubs(:url_base).returns(POKITDOK_TEST_URL)

      VCR.use_cassette 'auth' do
        @pokitdok = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET)
      end
    end

    it 'should default to the v4 api specification' do
      @pokitdok.api_url.must_equal 'http://localhost:5002/api/v4'
    end

    it 'should revert to the v3 api specification if requested' do
      VCR.use_cassette 'auth' do
        @pokitdok3 = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET, 'v3')
        @pokitdok3.api_url.must_equal 'http://localhost:5002/api/v3'
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

    describe 'Authorizations endpoint' do
      it 'should expose the authorizations endpoint' do
        query = JSON.parse(IO.read('spec/fixtures/authorizations.json'))

        VCR.use_cassette 'authorizations' do
          @authorizations = @pokitdok.authorizations query
        end

        check_meta_and_data @authorizations
        refute_empty @authorizations['data']
      end
    end

    describe 'Cash Prices endpoint' do
      it 'should expose the cash prices endpoint' do
        query = { cpt_code: '90658', zip_code: '94403' }

        VCR.use_cassette 'cash_prices' do
          @prices = @pokitdok.cash_prices query
        end

        check_meta_and_data @prices
        refute_empty @prices['data']
      end
    end

    describe 'Insurance Prices endpoint' do
      it 'should expose the insurance prices endpoint' do
        query = { cpt_code: '87799', zip_code: '32218' }

        VCR.use_cassette 'insurance_prices' do
          @prices = @pokitdok.insurance_prices query
        end

        check_meta_and_data @prices
        refute_empty @prices['data']
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

    describe 'Claims status endpoint' do
      it 'should expose the claims status endpoint' do
        query = JSON.parse(IO.read('spec/fixtures/claims_status.json'))
        VCR.use_cassette 'claims_status' do
          @claims_status = @pokitdok.claims_status(query)
        end

        check_meta_and_data @claims_status
        refute_empty @claims_status['data']

        assert_nil @claims_status['errors']
      end
    end

    describe 'Eligibility endpoint' do
      it 'should expose the eligibility endpoint' do
        @eligibility_query = {
          member: {
              birth_date: '1970-01-01',
              first_name: 'Jane',
              last_name: 'Doe',
              id: 'W000000000'
          },
          provider: {
              first_name: 'JEROME',
              last_name: 'AYA-AY',
              npi: '1467560003'
          },
          service_types: ['health_benefit_plan_coverage'],
          trading_partner_id: 'MOCKPAYER'
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

    describe 'Payers endpoint' do
      it 'should expose the payers endpoint' do
        VCR.use_cassette 'payers' do
          @payers = @pokitdok.payers(state: 'CA')
        end

        check_meta_and_data @payers
        refute_nil @payers['data']
        @payers['data'].size.must_equal 295
      end
    end

    describe 'Plans endpoint no args' do
      it 'should expose the plans endpoint' do
        query = {}

        VCR.use_cassette 'plans_no_args' do
          @plans = @pokitdok.plans(query)
        end

        check_meta_and_data @plans
        @plans['data'].must_be_instance_of Array
      end
    end

    describe 'Plans endpoint' do
      it 'should expose the plans endpoint' do
        query = {'state' => 'TX', 'plan_type' => 'PPO'}

        VCR.use_cassette 'plans' do
          @plans = @pokitdok.plans(query)
        end

        check_meta_and_data @plans
        @plans['data'].must_be_instance_of Array
      end
    end

    describe 'Providers endpoint' do
      it 'should expose the providers endpoint' do
        query = { npi: '1467560003' }

        VCR.use_cassette 'providers' do
          @providers = @pokitdok.providers(query)
        end

        check_meta_and_data @providers
        refute_nil @providers['data']
        @providers['data'].size.must_equal 4
      end
    end

    describe 'Referrals endpoint' do
      it 'should expose the referrals endpoint' do
        query = JSON.parse(IO.read('spec/fixtures/referrals.json'))

        VCR.use_cassette 'referrals' do
          @referrals = @pokitdok.referrals(query)
        end

        check_meta_and_data @referrals
        refute_nil @referrals['data']
        @referrals['data']['valid_request'].must_equal true
      end
    end

    describe 'Scheduling endpoints' do
      it 'should list the schedulers' do
        VCR.use_cassette 'scheduling' do
          @schedulers = @pokitdok.schedulers
        end

        check_meta_and_data @schedulers
      end

      it 'should give details on a specific scheduler' do
        VCR.use_cassette 'scheduling' do
          @scheduler = @pokitdok.scheduler({ id: '1234567' })
        end

        check_meta_and_data @scheduler
      end

      it 'should list appointment types' do
        VCR.use_cassette 'scheduling' do
          @appointment_types = @pokitdok.appointment_types
        end

        check_meta_and_data @appointment_types
      end

      it 'should give details on a specific appointment type' do
        VCR.use_cassette 'scheduling' do
          @appointment_type = @pokitdok.appointment_type({ id: '1234567' })
        end

        check_meta_and_data @appointment_type
      end

      it 'should add an open slot' do
        @query = JSON.parse(IO.read('spec/fixtures/referrals.json'))

        VCR.use_cassette 'scheduling' do
          @add_slot_response = @pokitdok.slots @query
        end

        check_meta_and_data @add_slot_response
      end

      it 'should query for open appointment slots' do
        VCR.use_cassette 'scheduling' do
          @pokitdok.get_open_appointment_slots({})
        end
      end

      it 'should book appointment for an open slot' do
        VCR.use_cassette 'scheduling' do
          @pokitdok.book_appointment({})
        end
      end

      it 'should update appointment attributes' do
        VCR.use_cassette 'scheduling' do
          @pokitdok.update_appointment({})
        end
      end

      it 'should cancel a specified appointment' do
        VCR.use_cassette 'scheduling' do
          @cancel_response = @pokitdok.cancel_appointment({ id: '123456' })
        end

        check_meta_and_data @cancel_response
      end

    end

    describe 'Trading Partners endpoint index' do
      it 'should expose the trading partners endpoint (index call)' do
        query = {}

        VCR.use_cassette 'trading_partners_index' do
          @trading_partners = @pokitdok.trading_partners(query)
        end

        check_meta_and_data @trading_partners
        @trading_partners['data'].must_be_instance_of Array
        @trading_partners['data'].length.must_be :>, 1
      end
    end

    describe 'Trading Partners endpoint get' do
      it 'should expose the trading partners endpoint (get call)' do
        query = { trading_partner_id: 'MOCKPAYER' }

        VCR.use_cassette 'trading_partners_get' do
          @trading_partners = @pokitdok.trading_partners(query)
        end

        check_meta_and_data @trading_partners
        @trading_partners['data'].must_be_instance_of Hash
      end
    end
  end
end
