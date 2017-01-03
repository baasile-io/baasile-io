require 'rails_helper'

RSpec.describe Route, type: :model do
  before :each do
    @route = create :route
  end

  describe "attributes" do
    describe "methods" do
      it "restricts array of methods" do
        expect(Route::ALLOWED_METHODS).to eq ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']

        @route.allowed_methods = Route::ALLOWED_METHODS
        expect(@route.valid?).to be_truthy

        @route.allowed_methods = ['INVALID_METHOD']
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:allowed_methods]).to_not be_empty
      end

      it "at least requires one method" do
        @route.allowed_methods = []
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:allowed_methods]).to_not be_empty
      end

      it "must be an array" do
        @route.allowed_methods = 'a string'
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:allowed_methods]).to_not be_empty

        @route.allowed_methods = 42
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:allowed_methods]).to_not be_empty
      end
    end

    describe "name" do
      it "must be filled with 2 to 255 characters" do
        @route.name = nil
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:name]).to_not be_empty

        @route.name = 'a'
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:name]).to_not be_empty

        @route.name = 'a' * 256
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:name]).to_not be_empty
      end
    end

    describe "description" do
      it "must be filled" do
        @route.description = nil
        expect(@route.valid?).to be_falsey
        expect(@route.errors.messages[:description]).to_not be_empty
      end
    end
  end
end
