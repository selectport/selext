require 'date'

RSpec.describe FTdate do

it 'accepts a yyyymmdd integer' do

    d = FTdate.new(20171102)
    expect(d.year).to eq 2017
    expect(d.month).to eq 11
    expect(d.day).to eq 2
    expect(d.full.class).to be Time
    expect(d.standard).to be 20171102
  end

  it 'accepts a yyyymmdd string ' do
    d=FTdate.new('20171014')
    expect(d.year).to eq 2017
    expect(d.month).to eq 10
    expect(d.day).to eq 14
    expect(d.full.class).to be Time
    expect(d.standard).to be 20171014
  end

  it 'accepts an iso8601-style date string (yyyy-mm-dd) ' do
    d=FTdate.new('2017-10-14')
    expect(d.year).to eq 2017
    expect(d.month).to eq 10
    expect(d.day).to eq 14
    expect(d.full.class).to be Time
    expect(d.standard).to be 20171014
  end

  it 'accepts a full iso8601-style date/time (2017-11-28T13:24:41-07:00)' do
    d=FTdate.new('2017-11-28T13:24:41-07:00')
    expect(d.year).to eq 2017
    expect(d.month).to eq 11
    expect(d.day).to eq 28
    expect(d.full.class).to be Time
    expect(d.standard).to be 20171128
  end

  it 'accepts a Time' do
    d=FTdate.new(Time.new(2017,07,04))
    expect(d.year).to eq 2017
    expect(d.month).to eq 7
    expect(d.day).to eq 4
    expect(d.full.class).to be Time
    expect(d.standard).to be 20170704
  end

  it 'accepts a Date' do
    d=FTdate.new(Date.new(2017,03,15))
    expect(d.year).to eq 2017
    expect(d.month).to eq 3
    expect(d.day).to eq 15
    expect(d.full.class).to be Time
    expect(d.standard).to be 20170315
  end

  
  it 'returns a day name given a date' do

    d=FTdate.new(Date.new(2017,11,5)) # sunday
    expect(d.day_name).to eq 'sunday'

    d=FTdate.new(Date.new(2017,11,6)) # monday
    expect(d.day_name).to eq 'monday'

    d=FTdate.new(Date.new(2017,11, 4))  # saturday
    expect(d.day_name).to eq 'saturday'

  end


  it 'handles normal business day identification (no calendars)' do

    a_sunday    = Date.new(2017, 11, 5)
    a_wednesday = Date.new(2017, 11, 1)

    d=FTdate.new(a_wednesday)
    expect(d.is_a_normal_business_day?).to be true
    expect(d.is_not_a_normal_business_day?).to be false

    expect(FTdate.new(a_sunday).is_a_normal_business_day?).to be false
    expect(FTdate.new(a_sunday).is_not_a_normal_business_day?).to be true

  end


end
