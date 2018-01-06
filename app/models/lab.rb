class Lab
  include Mongoid::Document
  field :title, type: String
  field :test_suite, type: String
  has_many :logs
  embeds_one :embedded_log
end
