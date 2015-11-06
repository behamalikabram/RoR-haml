module HomeHelper
  include StringifyAmount
  
  HELP_STEPS_NAMES = {1 => "How To Withdraw & Deposit", 2 => "How To Play Dice", 3 => "How To Play Live Frosty Flowers"}

  def help_step_name(n)
    HELP_STEPS_NAMES[n]
  end
end
