module WhereConditioner
  class NullSink < BasicObject
    def initialize obj
      @obj = obj
    end

    def method_missing symbol, *args
      @obj
    end
  end

  extend ActiveSupport::Concern

  def if condition, &block
    @last_condition = condition
    conditional @last_condition, &block
  end

  def unless condition, &block
    self.if !condition, &block
  end

  def else &block
    conditional !@last_condition, &block
  end

  def elsif condition, &block
    result = conditional (!@last_condition && condition), &block
    @last_condition = condition
    result
  end

  def where_if_present *args    
    if Hash === args.first && args.length == 1
      hash = WhereConditioner.recursive_compact(args.first)
      if hash.present?
        self.where hash
      else
        self
      end
    elsif String === args.first
      unless args.include? nil
        self.where *args
      else
        self
      end
    else
      self.where *args
    end
  end

private
  def conditional condition, &block
    if block_given?
      if condition
        self.instance_eval &block
      else
        self
      end
    else
      if condition
        self
      else
        NullSink.new(self)
      end
    end
  end

  def self.recursive_compact(hash)
    hash.dup.tap do |hash|
      hash.each do |key,value|
        case value
        when nil
          hash.delete key
        when Hash
          compacted = recursive_compact(value)
          if compacted.empty?
            hash.delete key
          else
            hash[key] = compacted
          end
        end
      end
    end
  end

end

module ActiveRecord
  class Relation
    include WhereConditioner
  end
end
