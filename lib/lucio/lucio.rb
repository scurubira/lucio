class Lucio
  def initialize(lexicon = Lexicon.new)
    @lexicon = lexicon
    @lexicon.add_function :+    , lambda{|items| items.reduce(0, :+)}
    @lexicon.add_function :*    , lambda{|items| items.reduce(1, :*)}
    @lexicon.add_function :-    , lambda{|items| case when items.size == 0; 0; else; head, tail = Lucio.behead(items); tail.empty? ? (head * -1) : tail.inject(head) {|subtraction, item| subtraction -= item}; end}
    @lexicon.add_function :/    , lambda{|items| case when items.size == 0; raise 'expects at least 1 arguments, given 0'; when items.size == 1; 1.0 / items[0]; else items.reduce{|result, item| result = result / item.to_f}; end}
    @lexicon.add_function :true , lambda{ true }
    @lexicon.add_function :false, lambda{ false }
    @lexicon.add_function :eql? , lambda{|items| items.map{|item| item == items[0]}.reduce{|memo, item| memo && item}}
    @lexicon.add_function :lt   , lambda{|items| items[0] < items[1] }

    @lexicon.add_macro    :let  , lambda{|lexicon, items| lexicon.add_function(items[0].to_sym, lambda{|it| (items[1].kind_of? Array) ? evaluate_tree(it.empty? ? items[1] : items[1] + [it]) : items[1]})}
    @lexicon.add_macro    :if   , lambda{|lexicon, items| evaluate_tree(items[0]) ? evaluate_tree(items[1]) : evaluate_tree(items[2]) }
    @lexicon.add_macro    :fn   , lambda{|lexicon, items| create_function(items) }
  end

  def eval(source_code)
    tree = Sparse.new.parse(source_code)
    ret = nil
    tree.each {|list| ret = evaluate_tree list}
    ret
  end

  private
  def evaluate_tree(tree)
    unless tree.empty?
      operator, list = Lucio.behead tree
      
      if operator.kind_of?(Symbol) || operator.kind_of?(Array)
        instruction = @lexicon.get operator

        if instruction
          if instruction[:type] == :function
            list.map! {|item| (item.kind_of? Array) ? item = evaluate_tree(item) : item}
            list.map! do |item| 
              if item.kind_of? Symbol
                op = @lexicon.get item
                if op.nil?
                  raise UnboundSymbolException.new("Unbound symbol #{item.to_s}")
                end
                item = op[:code].call [] 
              else
                item
              end
            end

            begin
              instruction[:code].call list
            rescue ArgumentError
              instruction[:code].call
            end

          elsif instruction[:type] == :macro
            instruction[:code].call @lexicon, list

          end

        else
          raise UnboundSymbolException.new "Unbound symbol #{operator.to_s}"

        end
      else
        operator
      end

    end
  end

  def self.behead(list)
    [list[0], list.drop(1)]
  end

  def create_function(items)
    items[1] = replace_parameters(items[1], items[0], items[2])
    evaluate_tree(items[1])
  end

  def replace_parameters(list, variables, values)
    unless variables.empty?
      (0 .. (variables.size - 1)).each do |i|
        list = list.map do |item| 
          if item.kind_of? Array
            item = replace_parameters(item, variables, values)
          else
            item == variables[i] ? values[i] : item
          end
        end
      end
    end

    list

  end

end

class UnboundSymbolException < Exception
end
