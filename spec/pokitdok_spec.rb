# encoding: UTF-8

require 'spec_helper'

CLIENT_ID = 'dklfjdklsf'
CLIENT_SECRET = 'djksfhsdjfh'
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
      flunk 'Not implemented'
    end

    describe 'Activities endpoint' do
      it 'should expose the activities endpoint' do
        @activities = @pokitdok.activities
        refute_nil @pokitdok.activities
        @pokitdok.activities.size.must_equal 5
      end
    end

    describe 'Cash Prices endpoint' do
      it 'should expose the cash prices endpoint' do
        refute_nil @pokitdok.cash_prices
      end
    end

    describe 'Eligibility endpoint' do
      it 'should expose the eligibility endpoint' do
        refute_nil @pokitdok.eligibility
      end
    end

    describe 'Enrollment endpoint' do
      it 'should expose the enrollment endpoint' do
        refute_nil @pokitdok.enrollment
      end
    end

    describe 'Files endpoint' do
      it 'should expose the files endpoint' do
        refute_nil @pokitdok.files
      end
    end

    describe 'Insurance Prices endpoint' do
      it 'should expose the insurance prices endpoint' do
        refute_nil @pokitdok.insurance_prices
      end
    end

    describe 'Payers endpoint' do
      it 'should expose the payers endpoint' do
        refute_nil @pokitdok.payers
      end
    end
  end
end
