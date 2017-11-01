module Tester
  class Result < ApplicationRecord

    belongs_to :route

    belongs_to :tester_requests_template,
               class_name: Tester::Requests::Template.name,
               foreign_key: 'tester_request_id'

    has_one :proxy, through: :route
    has_one :service, through: :route

  end
end