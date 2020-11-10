require 'date'

RSpec.describe 'Bank Days' do

  before(:all) do
    bank_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_bank_holidays(bank_holidays)

  end

  it 'considers bank holidays only those in the bank holiday calendar' do
    d = FTdate.new(Date.new(2017,07,05))
    expect(d.is_a_bank_holiday?).to be false
   
    d = FTdate.new(Date.new(2017,07,04))
    expect(d.is_a_bank_holiday?).to be true # in holiday calendar

    d = FTdate.new(Date.new(2017,11, 05))
    expect(d.is_a_bank_holiday?).to be false  # sunday; not considered a holiday
    
    d = FTdate.new(Date.new(2017, 11, 04))
    expect(d.is_a_bank_holiday?).to be false  # saturday; not considered a holiday
    
    d = FTdate.new(Date.new(2017,12,25))
    expect(d.is_a_bank_holiday?).to be true
  
  end

  it 'is a bank day if it is a business day and not a holiday' do
    d = FTdate.new(Date.new(2017, 07, 05))
    expect(d.is_a_bank_day?).to be true
  end

  it 'is not a bank day if it is not a business day' do
    d = FTdate.new(Date.new(2017, 11, 05)) # sunday
    expect(d.is_a_bank_day?).to be false
  end

  it 'is not a bank day if it is a business day but is a bank holiday' do
    d = FTdate.new(Date.new(2017, 07, 04))
    expect(d.is_a_bank_day?).to be false
  end

# ------------------------------------------------------------------------------

describe 'Adding Bank Days Arithmetic' do

    proc_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_bank_holidays(proc_holidays)

    grid  = [ [20170102,   0, 20170102],
              [20170102,   1, 20170103],
              [20170102,   2, 20170104],
              [20170703,   1, 20170705],
              [20170703,   5, 20170711],
              [20170701,   1, 20170703],
              [20171101,  30, 20171214]
           ]


  grid.each do |testcase|

    it "#{testcase[0]} plus #{testcase[1]} Bank days yields #{testcase[2]}" do

        begdate = FTdate.new(testcase[0])
        days    = testcase[1]
        exp_date = testcase[2]

        calc_date = begdate.add_bank_days(days)
        expect(calc_date.standard).to eq exp_date

    end

  end


end


# ------------------------------------------------------------------------------


describe 'Subtracting Bank Days Arithmetic' do

    proc_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_bank_holidays(proc_holidays)


    grid  = [ [20170102,   0, 20170102],
              [20170103,   1, 20170102],
              [20170104,   2, 20170102],
              [20170705,   1, 20170703],
              [20170711,   5, 20170703],
              [20170703,   1, 20170630],
              [20171214,  30, 20171101]
            ]


  grid.each do |testcase|

    it "#{testcase[0]} minus #{testcase[1]} Bank days yields #{testcase[2]}" do

        begdate = FTdate.new(testcase[0])
        days    = testcase[1]
        exp_date = testcase[2]

        calc_date = begdate.sub_bank_days(days)
        expect(calc_date.standard).to eq exp_date

    end

  end


end

end
