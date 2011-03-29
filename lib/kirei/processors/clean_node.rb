class Kirei  
  module Processors
    
    class CleanNode
      
      REGEX_PROTOCOL = /^([A-Za-z0-9\+\-\.\&\;\#\s]*?)(?:\:|&#0*58|&#x0*3a)/i
      
      
      def initialize(config)
        @config = config
      end
      
      def call(node)
        # remove node if its not white listed
        if node.elem? && !@config[:elements].include?(node.name)
          # maintain its children before removing it
          node.each_child { |child_node| node.before(child_node.to_html)  }

          # maintain whitespace for readability
          del = @config[:whitespace_elements].include?(node.name) ? " " : ""
          node.swap(del)

          return
        end

        # only elements have attributes 
        return unless node.elem?

        # if nothing then get out
        attributes = node.attributes.to_hash
        return if attributes.empty?

        # remove non whitelisted attrs and check for whitelisted protocols
        attributes.each do |attr_name, val|
          if !@config[:attributes].has_key?(node.name) || !@config[:attributes][node.name].include?(attr_name.downcase)
            node.remove_attribute(attr_name)
            next
          end

          if @config[:protocols].has_key?(node.name) && @config[:protocols][node.name].has_key?(attr_name)
            protocol = @config[:protocols][node.name][attr_name]

            del = if val.downcase =~ REGEX_PROTOCOL
                    !protocol.include?($1.downcase)
                  else
                    !protocol.include?(:relative)
                  end

            node.remove_attribute(attr_name) if del
          end
        end
        
      end
    end
    
  end
end