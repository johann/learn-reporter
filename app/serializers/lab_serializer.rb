class LabSerializer < ActiveModel::Serializer
  attributes :title, :test_suite, :log
  # has_many :logs


  def log
    if object.embedded_log
      EmbeddedLogSerializer.new(object.embedded_log)
    else
      {}
    end
  end
end
