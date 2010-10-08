require 'active_record'
require 'workflow'

module Foreman
  include ::Workflow

  module ClassMethods
    # Set the default state of this workflow
    # Explicitly specify the states of the workflow
    def states(*states)
      if states.last.is_a? Hash
        options = states.pop
      else
        options = {}
      end
      
      @__valid_states  = states.map { |state| state.to_sym }
      self.default_state = options[:default].to_sym || @__valid_states.first
      
      validates_inclusion_of :state, :in => valid_states
    end
  
    # Declare a workflow by yielding a Foreman::Workflow object
    def workflow(&block)
      raise "workflow already declared" if @__workflow
      @__workflow = Workflow.new
      @__workflow.instance_eval &block
    end
      
    # Return the list of valid sates    
    def valid_states; @__valid_states || []; end
    
    # Return the default state
    def default_state; @__default_state; end
    
    # Explicitly set the default state
    def default_state=(state)
      raise ArgumentError, "invalid state: #{state}" unless valid_states.include? state
      @__default_state = state
    end
  end
  
  # A Foreman workflow, not to be confused with the Workflow gem
  class Workflow
    def job_for(state, options = {})
    end
  end
  
  def self.included(klass)
    klass.send :extend, ClassMethods
  end
end