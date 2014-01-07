class Either
  attr_reader :value

  def initialize(val)
    @value = val
  end

  def success?
    is_a? Success
  end

  def failure?
    is_a? Failure
  end

  def self.try(val = nil, &blk)
    if val != nil
      case val
        when Success
          Success.new(val.value)
        when Failure
          Failure.new(val.value)
        when Exception
          Failure.new(val)
        else 
          Success.new(val)
      end
    elsif block_given?
      begin
        Success.new(blk.call)
      rescue Exception => e
        Failure.new(e)
      end
    else 
      raise ArgumentError
    end
  end

  class << self; protected :new; end
end

class Success < Either; class << self; public :new; end; end
class Failure < Either; class << self; public :new; end; end
