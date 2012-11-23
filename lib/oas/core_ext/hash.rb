require 'nokogiri'

Hash.class_eval do
  class << self
    def recursive_symbolize_keys!
      # symbolize_keys!
      # # symbolize each hash in .values
      # values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
      # # symbolize each hash inside an array in .values
      # values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
      # self

      symbolize_keys!
      values.each{|h|
        if Array === h
          h.each{|vv| vv.recursive_symbolize_keys! if Hash === vv }
        elsif Hash === h
          h.recursive_symbolize_keys!
        end
        }
    end
    # class << self
    def from_xml(xml_io)
      binding.pry
      result = Nokogiri::XML(xml_io)
      binding.pry
      return { result.root.name.to_sym => Hash.xml_node_to_hash(result.root) }
    end

    def xml_node_to_hash(node)
      # If we are at the root of the document, start the hash
      if node.element?
        result_hash = {}
        if node.attributes != {}
          node.attributes.keys.each do |key|
            result_hash[node.attributes[key].name.to_sym] = prepare(node.attributes[key].value)
          end
        end
        if node.children.size > 0
          node.children.each do |child|
            result = Hash.xml_node_to_hash(child)

            if child.name == "text"
              unless child.next_sibling || child.previous_sibling
                result = prepare(result)
                return result if result_hash.empty?
                result_hash[:content] = result
                return result_hash
              end
            elsif result_hash[child.name.to_sym]
              if result_hash[child.name.to_sym].is_a?(Object::Array)
                result_hash[child.name.to_sym] << prepare(result)
              else
                result_hash[child.name.to_sym] = [result_hash[child.name.to_sym]] << prepare(result)
              end
            else
              result_hash[child.name.to_sym] = prepare(result)
            end
          end
          return result_hash
        else
          return nil
        end
      else
        binding.pry
        return prepare(node.content.to_s)
      end
    end

    def prepare(data)
      (data.class == String && data.to_i.to_s == data) ? data.to_i : data
    end
  end

  def to_struct(struct_name)
    Struct.new(struct_name,*keys).new(*values)
  end
end