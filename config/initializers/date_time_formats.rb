# Standard site-wide date time
Time::DATE_FORMATS[:standard_date_time] = lambda { |date| date.strftime("%B %-d, %Y @ %l:%M%P") }

# e.g. Monday
Date::DATE_FORMATS[:day_name] = lambda { |date| date.strftime "%A" }
Time::DATE_FORMATS[:day_name] = lambda { |date| date.strftime "%A" }

# e.g. 6/9 (not 06/09), 10/23
Date::DATE_FORMATS[:month_day] = lambda { |date| date.strftime "%-m/%-d" }
Time::DATE_FORMATS[:month_day] = lambda { |date| date.strftime "%-m/%-d" }

# e.g. 6/9/2010 (not 06/09/2010), 10/23/2010
Date::DATE_FORMATS[:us] = lambda { |date| date.strftime "%-m/%-d/%Y" }
Time::DATE_FORMATS[:us] = lambda { |date| date.strftime "%-m/%-d/%Y" }

#e.g. 6/9/2010 2:34PM (not 06/09/2010), 10/23/2010
Time::DATE_FORMATS[:us_time] = lambda { |date| date.strftime "%-m/%-d/%Y %l:%M%p" }

# e.g. 2010-06-09
Date::DATE_FORMATS[:nat] = lambda { |date| date.strftime "%Y-%m-%d" }
Time::DATE_FORMATS[:nat] = lambda { |date| date.strftime "%Y-%m-%d" }

# e.g. June 6th
Date::DATE_FORMATS[:month_with_ordinal] = lambda { |date| date.strftime("%B #{date.day.ordinalize}") }
Time::DATE_FORMATS[:month_with_ordinal] = lambda { |date| date.strftime("%B #{date.day.ordinalize}") }

# e.g. June 6
Date::DATE_FORMATS[:full_month_day] = lambda { |date| date.strftime("%B %-d") }
Time::DATE_FORMATS[:full_month_day] = lambda { |date| date.strftime("%B %-d") }

# e.g.  Monday June 6th, 2011
Date::DATE_FORMATS[:full_date] = lambda { |date| date.strftime("%A %B #{date.day.ordinalize}, %Y") }
Time::DATE_FORMATS[:full_date] = lambda { |date| date.strftime("%A %B #{date.day.ordinalize}, %Y") }

# e.g.  June 6th, 2011
Date::DATE_FORMATS[:month_day_ordinal_yyyy] = lambda { |date| date.strftime("%B #{date.day.ordinalize}, %Y") }
Time::DATE_FORMATS[:month_day_ordinal_yyyy] = lambda { |date| date.strftime("%B #{date.day.ordinalize}, %Y") }

# e.g.  June 6, 2011
Date::DATE_FORMATS[:month_day_yyyy] = lambda { |date| date.strftime("%B %-d, %Y") }
Time::DATE_FORMATS[:month_day_yyyy] = lambda { |date| date.strftime("%B %-d, %Y") }

# e.g. June 6, 2011 @ 2:43pm
Date::DATE_FORMATS[:month_day_yyyy_at_time] = lambda { |date| date.strftime("%B %-d, %Y @ %l:%M%P") }
Time::DATE_FORMATS[:month_day_yyyy_at_time] = lambda { |date| date.strftime("%B %-d, %Y @ %l:%M%P") }

# e.g.  June 2012
Date::DATE_FORMATS[:month_year] = lambda { |date| date.strftime("%B %Y") }
Time::DATE_FORMATS[:month_year] = lambda { |date| date.strftime("%B %Y") }

# e.g.  2012-10-25
Date::DATE_FORMATS[:system] = lambda { |date| date.strftime("%Y-%m-%d") }
Time::DATE_FORMATS[:system] = lambda { |date| date.strftime("%Y-%m-%d") }

# e.g.  20121025
Date::DATE_FORMATS[:yyyymmdd] = lambda { |date| date.strftime("%Y%m%d") }
Time::DATE_FORMATS[:yyyymmdd] = lambda { |date| date.strftime("%Y%m%d") }

# e.g. Monday-YYYY-MM-DD, used for Google Analytics tracking
Date::DATE_FORMATS[:ga_date] = lambda { |date| date.strftime("%A-%Y-%m-%d") }
Time::DATE_FORMATS[:ga_date] = lambda { |date| date.strftime("%A-%Y-%m-%d") }

# e.g. Jul. 15, 2014
Date::DATE_FORMATS[:abrev_month_yyyy] = lambda { |date| date.strftime("%b. %-d, %Y") }
Time::DATE_FORMATS[:abrev_month_yyyy] = lambda { |date| date.strftime("%b. %-d, %Y") }

# e.g. Jul. 15
Date::DATE_FORMATS[:abrev_month] = lambda { |date| date.strftime("%b. %-d") }
Time::DATE_FORMATS[:abrev_month] = lambda { |date| date.strftime("%b. %-d") }

# e.g. Jul. 15th
Date::DATE_FORMATS[:abrev_month_ordinal] = lambda { |date| date.strftime("%b. #{date.day.ordinalize}") }
Time::DATE_FORMATS[:abrev_month_ordinal] = lambda { |date| date.strftime("%b. #{date.day.ordinalize}") }

# e.g. Jul. 15, 2014
Date::DATE_FORMATS[:full_month_yyyy] = lambda { |date| date.strftime("%B %-d, %Y") }
Time::DATE_FORMATS[:full_month_yyyy] = lambda { |date| date.strftime("%B %-d, %Y") }

# e.g. Jul. 15
Date::DATE_FORMATS[:full_month] = lambda { |date| date.strftime("%B %-d") }
Time::DATE_FORMATS[:full_month] = lambda { |date| date.strftime("%B %-d") }

# e.g. 2014
Date::DATE_FORMATS[:abrev_yyyy] = lambda { |date| date.strftime("%Y") }
Time::DATE_FORMATS[:abrev_yyyy] = lambda { |date| date.strftime("%Y") }

# e.g. 10:00 AM
Time::DATE_FORMATS[:abrev_time] = lambda { |date| date.strftime("%l:%M%p") }

# e.g. 10:00am
Time::DATE_FORMATS[:abrev_time_alternative] = lambda { |date| date.strftime("%l:%M%P") }
