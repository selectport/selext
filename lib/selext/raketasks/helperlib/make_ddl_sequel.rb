require 'mustache'

module Selext
class  MakeDDLSequel


def initialize(model_name, table_name)
  @model_name = model_name
  @table_name = table_name.to_sym
end

# ------------------------------------------------------------------------------
def generate

  context = {}

  context[:schema] = DB.dump_table_schema(@table_name, same_db: false)
  context[:model_name]  = @model_name
  context[:table_name]  = @table_name

  tmpl = fetch_template

  text = Mustache.render(tmpl, context)

end
 
# ------------------------------------------------------------------------------
private

def fetch_template

tmpl = <<ENDTEMPLATE
class {{model_name}}

def self.tblCreate

DB.{{{schema}}}

end  # tblCreate
end  # class
ENDTEMPLATE

end

# ------------------------------------------------------------------------------

end # class
end # module

