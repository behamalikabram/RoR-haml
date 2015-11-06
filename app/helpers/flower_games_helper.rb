module FlowerGamesHelper
  def flower_color_text(game)
    color = game.color
    if color == "Rainbow"
      "<span><font color='#FF0000'>R</font><font color='#FFDB00'>a</font><font color='#FFff00'>i</font><font color='#24ff00'>n</font><font color='#00ff00'>b</font><font color='#00ffDB'>o</font><font color='#00ffff'>w</font></span>"
    else 
      "<span class='#{color.downcase}'>#{color}</span>"
    end.html_safe
  end
end
