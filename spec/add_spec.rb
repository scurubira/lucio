require 'spec_helper'

describe Lucio do
  context 'add' do
    before :each do
      @lucio = Lucio.new
    end

    it 'without parameters should return zero' do
      @lucio.eval('(+)').should == 0
    end

    it 'with one value should return that value' do
      @lucio.eval('(+ 3)').should == 3
    end

    it 'with two values should return the sum' do
      @lucio.eval('(+ 3 5)').should == 8
    end

    it 'with nested lists should eval the list before return the sum' do
      @lucio.eval('(+ 3 (+ 3 2))').should == 8
    end

    it 'with neeeeeeesteeeeeeeed freeeeezy!' do
      @lucio.eval('(+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 (+ 3 2))))))))))))))').should == 44
    end

    it 'with invalid operator should raise error' do
      lambda {@lucio.eval('((+ 3 4))')}.should raise_error UnboundSymbolException
    end

  end
end
