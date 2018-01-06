class EmbeddedLogSerializer < ActiveModel::Serializer
  attributes :result, :duration, :examples, :passing_count, :pending_count, :failure_count, :failure_descriptions
end
