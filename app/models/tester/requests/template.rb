module Tester
  module Requests
    class Template < Request

      validates :name, presence: true

    end
  end
end