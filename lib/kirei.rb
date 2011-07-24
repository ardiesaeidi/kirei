require "hpricot"
require_relative "kirei/version"
require_relative "kirei/config"
require_relative "kirei/processors/clean_node"

class Kirei
  
  def self.clean(input, config = {})
    Kirei.new(config).clean(input)
  end
  
  def initialize(config = {})
    @config = Config::DEFAULT.merge(config)
    
    # set default processor to run after all others
    @config[:processors] << Processors::CleanNode.new(@config) 
  end
  
  def clean(input)
    doc = Hpricot(input)
    
    traverse_depth(doc) do |node|
      process_node(node)
    end
    
    doc.to_html
  end
  
  private
  def process_node(node)
    @config[:processors].each do |processor|
      processor.call(node)
    end
  end
  
  def traverse_depth(node, &block)
    if node.respond_to?(:children)
      node.each_child { |child_node|  traverse_depth(child_node, &block) }
    end
    
    block.call(node)
  end
end
