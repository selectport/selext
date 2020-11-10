require 'date'

RSpec.describe 'processing Days' do

  before(:all) do
    proc_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_proc_holidays(proc_holidays)

  end

  it 'considers processing holidays only those in the processing holiday calendar' do
    d = FTdate.new(Date.new(2017,07,05))
    expect(d.is_a_proc_holiday?).to be false
   
    d = FTdate.new(Date.new(2017,07,04))
    expect(d.is_a_proc_holiday?).to be true # in holiday calendar

    d = FTdate.new(Date.new(2017,11, 05))
    expect(d.is_a_proc_holiday?).to be false  # sunday; not considered a holiday
    
    d = FTdate.new(Date.new(2017, 11, 04))
    expect(d.is_a_proc_holiday?).to be false  # saturday; not considered a holiday
    
    d = FTdate.new(Date.new(2017,12,25))
    expect(d.is_a_proc_holiday?).to be true
  
  end

  it 'is a processing day if it is a business day and not a holiday' do
    d = FTdate.new(Date.new(2017, 07, 05))
    expect(d.is_a_proc_day?).to be true
  end

  it 'is not a processing day if it is not a business day' do
    d = FTdate.new(Date.new(2017, 11, 05)) # sunday
    expect(d.is_a_proc_day?).to be false
  end

  it 'is not a processing day if it is a business day but is a processing holiday' do
    d = FTdate.new(Date.new(2017, 07, 04))
    expect(d.is_a_proc_day?).to be false
  end

end

# ------------------------------------------------------------------------------

RSpec.describe 'Adding Processing Days Arithmetic' do

    proc_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_proc_holidays(proc_holidays)

    grid1 = [ [20170102,   0, 20170102],
              [20170102,   1, 20170103],
              [20170102,   2, 20170104],
              [20170703,   1, 20170705],
              [20170703,   5, 20170711],
              [20170701,   1, 20170703],
              [20171101,  30, 20171214]
           ]


  grid1.each do |testcase|

    it "#{testcase[0]} plus #{testcase[1]} processing days yields #{testcase[2]}" do

        begdate = FTdate.new(testcase[0])
        days    = testcase[1]
        exp_date = testcase[2]

        calc_date = begdate.add_proc_days(days)
        expect(calc_date.standard).to eq exp_date

    end

  end


end


# ------------------------------------------------------------------------------


RSpec.describe 'Subtracting Processing Days Arithmetic' do

    proc_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_proc_holidays(proc_holidays)


    grid2 = [ [20170102,   0, 20170102],
              [20170103,   1, 20170102],
              [20170104,   2, 20170102],
              [20170705,   1, 20170703],
              [20170711,   5, 20170703],
              [20170703,   1, 20170630],
              [20171214,  30, 20171101]
            ]


  grid2.each do |testcase|

    it "#{testcase[0]} minus #{testcase[1]} processing days yields #{testcase[2]}" do

        begdate = FTdate.new(testcase[0])
        days    = testcase[1]
        exp_date = testcase[2]

        calc_date = begdate.sub_proc_days(days)
        expect(calc_date.standard).to eq exp_date

    end

  end


end

# ------------------------------------------------------------------------------

RSpec.describe 'Processing Days Between Dates' do

    proc_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_proc_holidays(proc_holidays)


    grid3 = [ 
              [20170102,  20170102,   0],
              [20170103,  20170102,   1],
              [20170711,  20170703,   5],
              [20170703,  20170630,   1],
              [20171214,  20171101,  30],

              [20170102,  20170102,   0],
              [20170102,  20170103,   1],
              [20170703,  20170711,   5],
              [20170630,  20170703,   1],
              [20171101,  20171214,  30]
            ]

    grid3.each do |testcase|

      it "processing days between #{testcase[0]} and #{testcase[1]} yields #{testcase[2]}" do

        begdate  = FTdate.new(testcase[0])
        enddate  = FTdate.new(testcase[1])
        exp_days = testcase[2]

        calc_days = begdate.proc_days_between(enddate)
        expect(calc_days).to eq exp_days

      end

    end


end # describe processing days between

# ------------------------------------------------------------------------------

RSpec.describe 'Settlement Days Between Dates' do

    sett_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_sett_holidays(sett_holidays)


    grid3 = [ 
              [20170102,  20170102,   0],
              [20170103,  20170102,   1],
              [20170711,  20170703,   5],
              [20170703,  20170630,   1],
              [20171214,  20171101,  30],

              [20170102,  20170102,   0],
              [20170102,  20170103,   1],
              [20170703,  20170711,   5],
              [20170630,  20170703,   1],
              [20171101,  20171214,  30]
            ]

    grid3.each do |testcase|

      it "settlement days between #{testcase[0]} and #{testcase[1]} yields #{testcase[2]}" do

        begdate  = FTdate.new(testcase[0])
        enddate  = FTdate.new(testcase[1])
        exp_days = testcase[2]

        calc_days = begdate.sett_days_between(enddate)
        expect(calc_days).to eq exp_days

      end

    end


end # describe settlement days between


# ------------------------------------------------------------------------------

RSpec.describe 'Bank Days Between Dates' do

    bank_holidays = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_bank_holidays(bank_holidays)


    grid4 = [ 
              [20170102,  20170102,   0],
              [20170103,  20170102,   1],
              [20170711,  20170703,   5],
              [20170703,  20170630,   1],
              [20171214,  20171101,  30],

              [20170102,  20170102,   0],
              [20170102,  20170103,   1],
              [20170703,  20170711,   5],
              [20170630,  20170703,   1],
              [20171101,  20171214,  30]
            ]

    grid4.each do |testcase|

      it "bank days between #{testcase[0]} and #{testcase[1]} yields #{testcase[2]}" do

        begdate  = FTdate.new(testcase[0])
        enddate  = FTdate.new(testcase[1])
        exp_days = testcase[2]

        calc_days = begdate.bank_days_between(enddate)
        expect(calc_days).to eq exp_days

      end

    end


end # describe bank days between



# ------------------------------------------------------------------------------

RSpec.describe 'Business Days Between Dates' do

    biz_holidays  = [20170101,
                     20170407,
                     20170529,
                     20170704,
                     20170904,
                     20171123,
                     20171225
                     ]

    Fintypes.inject_biz_holidays(biz_holidays)


    grid5 = [ 
              [20170102,  20170102,   0],
              [20170103,  20170102,   1],
              [20170711,  20170703,   5],
              [20170703,  20170630,   1],
              [20171214,  20171101,  30],

              [20170102,  20170102,   0],
              [20170102,  20170103,   1],
              [20170703,  20170711,   5],
              [20170630,  20170703,   1],
              [20171101,  20171214,  30]
            ]

    grid5.each do |testcase|

      it "business days between #{testcase[0]} and #{testcase[1]} yields #{testcase[2]}" do

        begdate  = FTdate.new(testcase[0])
        enddate  = FTdate.new(testcase[1])
        exp_days = testcase[2]

        calc_days = begdate.biz_days_between(enddate)
        expect(calc_days).to eq exp_days

      end

    end


end # describe business days between

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
