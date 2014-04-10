require "awesome_print"
AwesomePrint.pry!
Pry.config.print = proc { |output,value| Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output) }
