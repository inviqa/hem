class Slop
  attr_accessor :long_desc, :arg_list, :hidden
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