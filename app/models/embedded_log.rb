class EmbeddedLog
  include Mongoid::Document
  field :result, type: String
  field :examples, type: Integer
  field :pending_count, type: Integer
  field :failure_count, type: Integer
  field :passing_count, type: Integer
  field :test_ran, type: Boolean
  field :failure_descriptions, type: String
  field :duration, type: Float
  embedded_in :lab
end


#Log
