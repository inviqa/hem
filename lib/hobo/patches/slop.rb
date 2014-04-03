class Slop
  attr_accessor :long_desc, :arg_list, :hidden, :desc, :unparsed

  # Slop has a description method but it uses @config which is inherited
  # This is not desired behaviour
  def description desc = nil
    @desc = desc if desc
    @desc
  end

  def long_description desc = nil
    @long_desc = desc if desc
    @long_desc
  end

  def arg_list list = nil
    @arg_list = list if list
    @arg_list
  end

  def hidden value = nil
    @hidden = value if value
    @hidden
  end

  def project_only value = nil
    @config[:project_only] = value unless value.nil?
    @config[:project_only]
  end

  alias :old_parse! :parse!
  def parse!(items = ARGV, &block)
    if @unparsed.nil?
      split_index = items.index('--')

      unparsed = []
      unless split_index.nil?
        unparsed = items.slice(split_index + 1, items.length)
        items = items.slice(0, split_index)
      end

      @unparsed = unparsed.map do |c|
        "\'#{c.gsub("'", '\\\'').gsub('(', '\\(').gsub(')', '\\)')}\'"
      end.join(' ')
    end

    old_parse!(items, &block)
  end
end
