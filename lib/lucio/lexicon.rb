class Lexicon
  def initialize
    @operator_list = {}
  end

  def add_function(token, code)
    @operator_list[token] = {:type => :function, :code => code}
  end

  def add_macro(token, code)
    @operator_list[token] = {:type => :macro, :code => code}
  end

  def get(operator)
    @operator_list[operator]
  end
=begin
  def operator_list
    list = []
    @operator_list.each{|item| list << item[0] }
    list
  end
=end
end
