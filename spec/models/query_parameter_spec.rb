require 'rails_helper'

RSpec.describe QueryParameter, type: :model do
  before :each do
    @query_parameter = create :query_parameter
  end

  describe "attributes" do
    describe "name" do
      it "is required" do
        @query_parameter.name = nil
        expect(@query_parameter.valid?).to be_falsey
        expect(@query_parameter.errors.messages[:name]).to_not be_empty
      end

      it "is unique by route" do
        route1 = create :route
        route2 = create :route

        name = 'test'

        query_parameter1 = create :query_parameter, route: route1, name: name
        expect(query_parameter1.valid?).to be_truthy

        query_parameter2 = create :query_parameter, route: route2, name: name
        expect(query_parameter2.valid?).to be_truthy

        query_parameter3 = build :query_parameter, route: route2, name: name
        expect(query_parameter3.valid?).to be_falsey
        expect(query_parameter3.errors.messages[:name]).to_not be_empty
      end
    end
    describe "mode" do
      it "is beetween 1-3" do

        @query_parameter.mode = 1
        expect(@query_parameter.valid?).to be_truthy

        @query_parameter.mode = 2
        expect(@query_parameter.valid?).to be_truthy

        @query_parameter.mode = 3
        expect(@query_parameter.valid?).to be_truthy

        expect {
          @query_parameter.mode = 4
        }.to raise_error ArgumentError

        expect {
          @query_parameter.mode = 0
        }.to raise_error ArgumentError
      end
    end
  end
end
