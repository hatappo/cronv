# encoding: utf-8

require 'set'

module Crontav

  class Visualizer

    def initialize(cron_settings) 
      cron_settings = crontab_l unless cron_settings
      @cron_settings = cron_settings
    end

    def show(goal = nil)
      normalized_cron_settings = parse_and_normalize()

      now = Time.now
      default_goal_time = now + (60 * 60 * 24) # デフォルトは24時間後まで
      t = Time.new(now.year, now.month, now.day, now.hour, now.min, 0)
      if goal.is_a?(Time)
        goal_time = default_goal_time if goal <= now
      elsif goal.is_a?(Integer)
        goal_time = now + goal
      end
        

      skipped = false
      puts " ┏━━━ #{t}. Displaying from."
      while t.to_i < goal_time.to_i do
        active_list = []
        normalized_cron_settings.each do |cron|
          if hit?(cron, t)
            active_list << " #{t.to_s} -> #{cron[5]}"
          end
        end
        if active_list.size == 0
          if not skipped
            # puts " ┃"
            print " ・\n ・\n ・\n"
          end
          skipped = true

        elsif active_list.size == 1
          puts " ┣━━━" + active_list.join("\n ┃ ┗━")
          skipped = false
        else
          puts " ┣━┳━" + active_list[0..-2].join("\n ┃ ┣━") + "\n ┃ ┗━" + active_list[-1]
          skipped = false
        end
         t = increment_minute(t)
      end
      puts " ┗━━━ #{t} Displayed to."
    end

    def hhmm(time)
      sprintf("           %02d:%02d", time.hour, time.min)
    end

    def yyyymmddhhmm(time)
      sprintf("%04d-%02d-%02d %02d:%02d", time.year, time.month, time.day, time.hour, time.min)
    end

    def hit?(cron, time)
      return false unless (cron[0].include?(time.min) and cron[1].include?(time.hour) and cron[3].include?(time.month))
      cron[2].include?(time.day) or cron[4].include?(time.wday)
    end

    def increment_minute(time)
      time + 60 # TODO うるう秒とか大丈夫か。
    end

    def parse_and_normalize()
      normalized_cron_settings = []
      @cron_settings.split("\n").each do |cron|
        _cron = cron.strip
        next if _cron.empty? or _cron.start_with?("#")
        minute, hour, day, month, week, command = _cron.split(/\s+/, 6)
        raise RuntimeError, "TODO" unless command
        minute_list = normalize(minute, 59, 0)
          hour_list = normalize(hour,   23, 0)
           day_list = normalize(day,    31, 1)
         month_list = normalize(month,  12, 1)
          week_list = normalize(week,    7, 0)
          # 0 と 7 がともに日曜日を表現しているので 0 に集約する。
          if week_list.include?(0) or week_list.include?(7)
            week_list.unshift(0) unless week_list.first  == 0
            week_list.pop if week_list.last == 7
          end

          normalized_cron_settings << [minute_list, hour_list, day_list, month_list, week_list, command]
      end
      normalized_cron_settings
    end

    def normalize(schedule_element, max, min)
      timing_set = Set.new
      if schedule_element == "*"
        timing_set = Set.new(Range.new(min, max))
      else
        schedule_element.split(",").each { |e| timing_set.merge(parse(e, max, min)) }
      end
      timing_set.to_a.sort
    end

    def parse(element_parts, max, min)
      empty_set = Set.new
      case
      when element_parts.start_with?("*/")
        # 「n単位毎の実行」の表記
        interval = element_parts[2..-1]
        return empty_set unless unsigned_number_format?(interval)
        # */n 表記において、crontabの仕様ではnは1以上であれば、例えば100でもOKだが、maxで区切る。
        return empty_set unless interval.to_i.between?(1, max)
        return Set.new(Range.new(min, max).select { |time| time.to_i % interval.to_i == 0 })

      when element_parts.include?("-")
        # 「n〜mにおいて毎回実行」の表記
        fromAndTo = element_parts.split("-")
        return empty_set unless unsigned_number_format?(fromAndTo[0])
        return empty_set unless unsigned_number_format?(fromAndTo[1])
        from = fromAndTo[0].to_i
        to   = fromAndTo[1].to_i
        return empty_set unless from.between?(min, max) and to.between?(min, max) and from <= to
        return Set.new(Range.new(from, to))

      else
        # 「（単純に）nの時に」の表記
        return empty_set unless unsigned_number_format?(element_parts)
        return empty_set unless element_parts.to_i.between?(min, max)
        return Set.new([element_parts.to_i])
      end
    end

    def unsigned_number_format?(number_expression)
      number_expression =~ /^[0-9]+$/
    end

    def crontab_l()
      IO.popen("crontab -l", "r:utf-8") {|io| io.read }
    end

  end
end
