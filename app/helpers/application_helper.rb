module ApplicationHelper
  CURRENT_PATHS = {wallet: [:transfer, :wallet, :deposit, :withdraw]}

  def cp(name, as_path: false)
    curr = if as_path
      request.fullpath == name
    else
      name = name.to_s
      request.fullpath.include?(name)
    end
    "current" if curr
  end

  def yesno(bool)
    bool ? "yes" : "no"
  end
end
