require "helper"

CLIENT_ID = "dklfjdklsf"
CLIENT_SECRET = "djksfhsdjfh"
POKITDOK_TEST_URL = "http://localhost:5002/api"

describe PokitDok do
    before do
        PokitDok.any_instance.stubs(:pokitdok_url).returns(POKITDOK_TEST_URL)
    end

    describe "Basic functionality" do
        it "should instantiate with a client id and client secret" do
            @pokitdok = PokitDok.new(CLIENT_ID, CLIENT_SECRET)
            refute_nil(@pokitdok, "New PokitDok was nil.")
        end
    end

    describe "Authentication functions" do
        it "should authenticate on a new connection" do
            @pokitdok = PokitDok.new(CLIENT_ID, CLIENT_SECRET)
            refute_empty @pokitdok.access_token
        end

        it "should refresh the connection if it expires" do
            flunk "Not implemented"
        end
    end

    describe "Endpoint functions" do
        before do
            @pokitdok = PokitDok.new(CLIENT_ID, CLIENT_SECRET)
        end

        describe "Activities endpoint" do
            it "should expose the activities endpoint" do
                flunk "Not implemented"
            end
        end
        
        describe "Cash Prices endpoint" do
            it "should expose the cash prices endpoint" do
                flunk "Not implemented"
            end
        end

        describe "Eligibility endpoint" do
            it "should expose the eligibility endpoint" do
                flunk "Not implemented"
            end
        end
        
        describe "Enrollment endpoint" do
            it "should expose the enrollment endpoint" do
                flunk "Not implemented"
            end
        end

        describe "Files endpoint" do
            it "should expose the files endpoint" do
                flunk "Not implemented"
            end
        end

        describe "Insurance Prices endpoint" do
            it "should expose the insurance prices endpoint" do
                flunk "Not implemented"
            end
        end

        describe "Payers endpoint" do
            it "should expose the payers endpoint" do
                flunk "Not implemented"
            end
        end
    end
end