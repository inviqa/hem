require 'slop'

class Slop
  attr_accessor :long_desc, :arg_list, :hidden, :desc

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
end