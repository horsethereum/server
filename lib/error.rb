class Error
  attr_reader :status, :error, :message

  def initialize(obj = {})
      case obj
      when Hash
        @status  = obj[:status]  || 400
        @error   = obj[:error]   || 'error'
        @message = obj[:message] || 'error'
      when String
        @status  = 400
        @error   = 'error'
        @message = obj
      when ActiveModel::Validations
        @status  = 400,
        @error   = 'validation_error'
        @message = obj.errors.messages.to_a.map(&:flatten).map { |l| l.join(' ') }.join(', ')
      else
        raise TypeError, "#{obj.class} not supported"
      end
  end

  def to_json
    { status: @status, error: @error, message: @message }.to_json
  end
end

