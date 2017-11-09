module Tester
  module Parameters
    class Query < Parameter

      validates :name, presence: true, format: {with: /\A[-_a-zA-Z0-9\[\]]+\z/}

    end
  end
end