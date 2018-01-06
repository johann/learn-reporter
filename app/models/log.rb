class Log
  include Mongoid::Document
  after_create :update_lab


  field :result, type: String
  field :examples, type: Integer
  field :pending_count, type: Integer
  field :failure_count, type: Integer
  field :passing_count, type: Integer
  field :test_ran, type: Boolean
  field :failure_descriptions, type: String
  field :duration, type: Float
  belongs_to :lab


  def update_lab
    embedded_log = EmbeddedLog.new(examples:self.examples, pending_count: self.pending_count, passing_count:self.passing_count, failure_count:self.failure_count, failure_descriptions: self.failure_descriptions, result: self.result, duration: self.duration)
    lab.embedded_log = embedded_log
    lab.save
  end

end


#Log
