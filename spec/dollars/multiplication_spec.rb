require_relative './../../lib/fintypes.rb'

RSpec.describe 'dollar multiplication' do

  it 'multiplies dollars by integers' do
    d=Dollars.new(2000)   # 20.00
    expect(d.times(5)).to eq 10000  # 100.00
  end
  
  it 'multiplies dollars by shares to return dollars' do
    d = Dollars.new(2000)  # 20.00
    s = Shares.new(10000)  # 10.000
    expect(d.times(s)).to eq 20000  # 200.00

    s = Shares.new(100.123)
  end
end
