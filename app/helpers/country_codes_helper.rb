module CountryCodesHelper
  def country_codes_for_autocomplete
    Countries::CODE_TO_NAME.map do |value, label|
      { label: "#{label} (#{value})", value: value }
    end
  end
end
