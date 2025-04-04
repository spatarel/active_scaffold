module ActiveScaffold::DataStructures
  class Set
    include Enumerable
    include ActiveScaffold::Configurable

    def initialize(*args)
      set_values(*args)
    end

    def initialize_dup(other)
      @set = other.set.dup
    end

    def set_values(*args)
      @set = []
      add(*args)
    end

    # the way to add items to the set.
    def add(*args)
      args.flatten! # allow [] as a param
      args.each do |arg|
        arg = arg.to_sym if arg.is_a? String
        @set << arg unless @set.include? arg # avoid duplicates
      end
    end
    alias << add

    # the way to remove items from the set.
    def exclude(*args)
      args.flatten! # allow [] as a param
      args.collect!(&:to_sym) # symbolize the args
      # check respond_to? :to_sym, ActionColumns doesn't respond to to_sym
      @set.reject! { |c| c.respond_to?(:to_sym) && args.include?(c.to_sym) } # reject all items specified
    end
    alias remove exclude

    # returns an array of items with the provided names
    def find_by_names(*names)
      @set.find_all { |item| names.include? item }
    end

    # returns the item of the given name.
    def find_by_name(name)
      # this works because of `def item.=='
      @set.find { |c| c == name }
    end
    alias [] find_by_name

    def each(&)
      @set.each(&)
    end

    # returns the number of items in the set
    def length
      @set.length
    end

    def empty?
      @set.empty?
    end

    def +(other)
      self.class.new(@set, *other)
    end

    protected

    attr_reader :set
  end
end
