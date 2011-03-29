class Kirei  
  module Processors
    
    class CleanNode
      
      REGEX_PROTOCOL = /^([A-Za-z0-9\+\-\.\&\;\#\s]*?)(?:\:|&#0*58|&#x0*3a)/i
      FORBIDDEN_PATTERNS = /(expression|eval|vbscript|javascript|<!---->)/i
      
      def initialize(config)
        @config = config
      end
      
      def call(node)
        
        # remove bogus malformed tags
        if node.bogusetag?
          node.swap("")
          return
        end
        
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

        # clean attributes
        node.attributes.to_hash.each do |attr_name, val|
          
          attr_name = attr_name.downcase
          
          # remove non whitelisted attributes
          if !@config[:attributes].has_key?(node.name) || !@config[:attributes][node.name].include?(attr_name)
            node.remove_attribute(attr_name)
            next
          end

          # check whitelisted protocols
          if @config[:protocols].has_key?(node.name) && @config[:protocols][node.name].has_key?(attr_name)
            protocol = @config[:protocols][node.name][attr_name]

            del = if val.downcase =~ REGEX_PROTOCOL
                    !protocol.include?($1.downcase)
                  else
                    !protocol.include?(:relative)
                  end

            if del
              node.remove_attribute(attr_name)
              next
            end
          end
          
          # does one final pass to see if any malicious patterns were found
          node.remove_attribute(attr_name) if val.gsub(/[\s\t\n\r]/, "") =~ FORBIDDEN_PATTERNS
        end
      end
    
    end
    
  end
end