Given /^a (\S+)(.*)?$/ do |model, stuff|
  # Given a hammer with nails for the toolbox -> create(:hammer, :with_nails, toolbox: @toolbox)
  # Given a fish with 2 bicycles -> create(:fish, :with_bicycles, bicycle_count: 2)
  traits = []
  options = {}

  raw_traits = ''
  raw_relations = ''

  if stuff =~ /with (.*)/ # has 'with', might have 'for the'
    raw_traits, raw_relations = $1.strip.split(' for the ')
  elsif stuff =~ /for the (.*)/ # might have 'for the'
    raw_relations = $1.strip.split(', ')
  end

  raw_traits.split(",").each do |trait|
    # "things" | "1 thing"
    traits << if trait =~ /^(\d+)\s+(.*)$/
      name = $2.strip.gsub(' ', '_')
      options["#{name.signularize}_count"] = $1.strip.to_i
      "with_#{name.pluralize}"
    else
      "with_#{trait.strip.pluralize.gsub(' ', '_')}"
    end.to_sym
  end if raw_traits

  raw_relations.split(',').each do |relation|
    options[relation.to_sym] = instance_variable_get("@#{relation}")
  end if raw_relations

  #traitdesc = ", " + traits.map(&:inspect).join(", ") unless traits.empty?
  #optdesc = ", " + options.map{|k,v| "#{k}: #{v.inspect}" }.join(", ") unless options.empty?
  #puts "Given a #{model}#{with_stuff} --> @#{model} = create(#{model.to_sym.inspect}#{traitdesc}#{optdesc})"

  instance_variable_set("@#{model}".to_sym,
                        create(model.to_sym, *traits, *options))
end
