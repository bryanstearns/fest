module PermittedParams
  def self.new(params)
    ActionController::Parameters.new(params).permit(*params.keys())
  end
end
