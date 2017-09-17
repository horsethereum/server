models=File.dirname(File.expand_path(__FILE__))
Dir["#{models}/*.rb"].each do |model|
  require_or_load model
end

