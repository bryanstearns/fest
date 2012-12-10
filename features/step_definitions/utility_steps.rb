Given /^a (\S+)( with (.*))?$/ do |model, with_stuff, stuff|
  # Given a hammer with nails -> create(:hammer, :with_nails)
  # Given a fish with 2 bicycles -> create(:fish, :with_bicycles, bicycle_count: 2)
  traits = []
  options = {}
  stuff.split(",").each do |trait|
    # "things" | "1 thing"
    traits << if trait =~ /^(\d+)\s+(.*)$/
      name = $2.strip.gsub(' ', '_')
      options["#{name.signularize}_count"] = $1.strip.to_i
      "with_#{name.pluralize}"
    else
      "with_#{trait.strip.pluralize.gsub(' ', '_')}"
    end.to_sym
  end if stuff

  #traitdesc = ", " + traits.map(&:inspect).join(", ") unless traits.empty?
  #optdesc = ", " + options.map{|k,v| "#{k}: #{v.inspect}" }.join(", ") unless options.empty?
  #puts "Given a #{model}#{with_stuff} --> @#{model} = create(#{model.to_sym.inspect}#{traitdesc}#{optdesc})"

  instance_variable_set("@#{model}".to_sym,
                        create(model.to_sym, *traits, *options))
end
