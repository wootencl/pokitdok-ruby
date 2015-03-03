# encoding: UTF-8

require 'spec_helper'

CLIENT_ID = 'jlHrMhG8CZudpJXHp0Rr'
CLIENT_SECRET = '347iuIN8T7zOzE7wtyk1vQGfjxuTE3yjxb8nlFev'
SCHEDULE_AUTH_CODE = 'KmCCkuYkSmPEf7AxaCIUApX1pUFedJx9CrDWPMD8'
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
        @pokitdok.scope_code('user_schedule', SCHEDULE_AUTH_CODE)
      end
    end

    it 'should default to the v4 api specification' do
      @pokitdok.api_url.must_match /.*v4.*/
    end

    it 'should revert to the v3 api specification if requested' do
      VCR.use_cassette 'auth' do
        @pokitdok3 = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET, 'v3')
        @pokitdok3.api_url.must_match /.*v3.*/
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
        @payers['data'].length.must_be :>, 1
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
        @schedulers['data'].length.must_be :>, 1
      end

      it 'should give details on a specific scheduler' do
        VCR.use_cassette 'scheduling' do
          @scheduler = @pokitdok.scheduler({ uuid: '967d207f-b024-41cc-8cac-89575a1f6fef' })
        end

        check_meta_and_data @scheduler
        @scheduler['data'].length.must_equal 1
        @scheduler['data'].first['name'].must_equal "Greenway"
      end

      it 'should list appointment types' do
        VCR.use_cassette 'scheduling' do
          @appointment_types = @pokitdok.appointment_types
        end

        check_meta_and_data @appointment_types
        @appointment_types['data'].length.must_be :>, 1
      end

      it 'should give details on a specific appointment type' do
        VCR.use_cassette 'scheduling' do
          @appointment_type = @pokitdok.appointment_type({ uuid: 'ef987695-0a19-447f-814d-f8f3abbf4860' })
        end

        check_meta_and_data @appointment_type
        @appointment_type['data'].length.must_equal 1
        @appointment_type['data'].first['type'].must_equal "OV1"
      end

      it 'should query for open appointment slots' do
        VCR.use_cassette 'scheduling_scoped' do
          @slots = @pokitdok.open_appointment_slots({
            start_date: "2015-01-01T00:00:00",
            end_date: "2015-02-05T00:00:00",
            appointment_type: "office_visit",
            patient_uuid: "8ae236ff-9ccc-44b0-8717-42653cd719d0"
          })
        end

        check_meta_and_data @slots
        @slots['data'].length.must_be :>, 1
      end

      it 'should book appointment for an open slot' do
        appt_uuid = "ef987691-0a19-447f-814d-f8f3abbf4859"
        booking_query = {
          patient: {
              _uuid: "500ef469-2767-4901-b705-425e9b6f7f83",
              email: "john@johndoe.com",
              phone: "800-555-1212",
              birth_date: "1970-01-01",
              first_name: "John",
              last_name: "Doe",
              member_id: "M000001"
          },
          description: "Welcome to M0d3rN Healthcare"
        }

        VCR.use_cassette 'scheduling_scoped' do
          @response = @pokitdok.book_appointment(appt_uuid, booking_query)
        end

        check_meta_and_data @response
        @response['data']['booked'].must_equal true
      end

      it 'should update appointment attributes' do
        appt_uuid = "ef987691-0a19-447f-814d-f8f3abbf4859"
        update_query = {
          description: "Welcome to M0d3rN Healthcare"
        }

        VCR.use_cassette 'scheduling_scoped' do
          @response = @pokitdok.update_appointment(appt_uuid, update_query)
        end

        check_meta_and_data @response
      end

      it 'should cancel a specified appointment' do
        VCR.use_cassette 'scheduling_scoped' do
          @cancel_response =
            @pokitdok.cancel_appointment "ef987691-0a19-447f-814d-f8f3abbf4859"
        end

        @cancel_response.must_equal true
      end

      it 'should raise an ArgumentError if a scoped method is' \
         ' called without a scope code being set' do
        VCR.use_cassette 'auth' do
          @pd = PokitDok::PokitDok.new(CLIENT_ID, CLIENT_SECRET)
        end

        assert_raises(ArgumentError) do
          @pd.cancel_appointment({ id: '123456' })
        end
      end
    end

    describe 'Trading Partners endpoints' do
      it 'should expose the trading partners endpoint (index call)' do
        query = {}

        VCR.use_cassette 'trading_partners_index' do
          @trading_partners = @pokitdok.trading_partners(query)
        end

        check_meta_and_data @trading_partners
        @trading_partners['data'].must_be_instance_of Array
        @trading_partners['data'].length.must_be :>, 1
      end

      it 'should expose the trading partners endpoint (get call)' do
        VCR.use_cassette 'trading_partners_get' do
          @trading_partners = @pokitdok.trading_partners({ trading_partner_id: 'aetna' })
        end

        check_meta_and_data @trading_partners
        @trading_partners['data'].must_be_instance_of Hash
        @trading_partners['data']['name'].must_equal "Aetna"
      end
    end
  end
end
