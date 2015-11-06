module StringifyAmountModel
  extend ActiveSupport::Concern
  include StringifyAmount

  def validate_correct_string_amount(string_amount, attr_name)
    return errors.add(attr_name, "can't be blank") if string_amount.blank?
    actual_amount = numerify_string(string_amount)
    return errors.add(attr_name, "format is invalid.") unless actual_amount
    actual_amount
  end
end