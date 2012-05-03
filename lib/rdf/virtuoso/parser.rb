module RDF
  module Virtuoso
    module Parser
      class JSON

        def self.call(response)
          parse_json_bindings(response)
        end

        def self.parse_json_bindings(response)
          case
          when response['boolean']
            response['boolean']
          when response['results']
            solutions = response['results']['bindings'].map do |row|
              row = row.inject({}) do |cols, (name, value)|
                cols.merge(name.to_sym => parse_json_value(value))
              end
              RDF::Query::Solution.new(row)
            end
            RDF::Query::Solutions.new(solutions)
          end
        end

        def self.parse_json_value(value, nodes = {})
          case value['type'].to_sym
          when :bnode
            nodes[id = value['value']] ||= RDF::Node.new(id)
          when :uri
            RDF::URI.new(value['value'])
          when :literal
            RDF::Literal.new(value['value'], :language => value['xml:lang'])
          when :'typed-literal'
            RDF::Literal.new(value['value'], :datatype => value['datatype'])
          else nil
          end
        end    

      end
    end
  end
end
