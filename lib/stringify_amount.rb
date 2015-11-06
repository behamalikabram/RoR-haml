module StringifyAmount
  extend ActiveSupport::Concern
  # Must be in descendace order
  # Also note downcase method in #numerify_string. 
  # If you want to change values to "M", "K", turn it into String#upcase
  DELIMITERS = {"b" => 1000000000, "m" => 1000000, "k" => 1000}
  AMOUNT_REGEX = /\A(\d+[\.\,]?\d*)\s*(#{DELIMITERS.keys.join('|')})?\z/i
  
  def stringify_amount(amount)
    return nil if !amount or !amount.respond_to?(:to_i)
    string_amount = amount.to_i
    DELIMITERS.each do |k, v|
      if string_amount >= v
        rounded_amount = (string_amount.to_f/v).round(2)
        rounded_amount = rounded_amount.to_i if (rounded_amount % 1 == 0)
        string_amount = rounded_amount.to_s << k
        break
      end
    end
    string_amount 
  end

  def numerify_string(string)
    return nil unless string.respond_to?(:to_s) 
    return nil unless string.to_s =~ AMOUNT_REGEX
    number, modifier = $1, $2
    number = number.gsub(",", ".").to_f
    modifier ? DELIMITERS[modifier.downcase]*number : number
  end

  module_function :numerify_string

  module ClassMethods
    def numerify_string_values!(*objects)
      objects.each do |obj|
        if obj.is_a?(Hash)
          obj.each { |k, v| obj[k] = StringifyAmount.numerify_string(v) }
        elsif obj.is_a?(Array)
          obj.map! {|v| StringifyAmount.numerify_string(v) }
        else
          raise ArgumentError.new("Not a hash or an array")
        end
      end
    end
  end
end