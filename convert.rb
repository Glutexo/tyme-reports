#!/usr/bin/env ruby

require 'csv'
require 'ruby-duration'

by_date = {}
CSV.new(
  ARGF.file,
  col_sep: ';',
  headers: true
).each do |row|
  by_task = begin
              date = Date.strptime row[1], '%d.%m.%y'
              by_date[date] = {} unless by_date.has_key? date
              by_date[date]
  end

  task = begin
           task = row[8]
           by_task[task] = [] unless by_task.has_key? task
           by_task[task]
  end

  task << begin
            duration = {}
            duration[:hours], duration[:minutes] = row[11].split(':').map &:to_i
            Duration.new duration
  end
end

puts CSV.generate col_sep: ';' do |csv|
  total_sum = Duration.new 0
  by_date.keys.sort.each do |date|
    by_date[date].keys.sort.each do |task|
      day_task_sum = Duration.new 0
      by_date[date][task].each do |duration|
        day_task_sum += duration
        total_sum += duration
      end
      csv << [date.strftime('%Y-%m-%d'), task, day_task_sum.format('%th h %m m')]
    end
  end
  csv << ['Total', '', total_sum.format('%th h %m m')]
end
