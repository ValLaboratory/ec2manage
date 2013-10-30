class Date
  # 平日ならtrue
  def weekday?
    not weekend?
  end

  # 土日ならtrue
  def weekend?
    sunday? or saturday?
  end
end

module Ec2manage
  class Instance
    def initialize(instance)
      @instance = instance
      @id = instance.id
      @statuses = get_statuses(instance.tags)
    end

    # tagsに不正がなければtrue
    def good?
      not @statuses.include?(:error)
    end

    attr_reader :id

    def name
      @statuses[:name]
    end

    def error
      @statuses[:error]
    end

    def start_hour
      @statuses[:start_hour]
    end

    def stop_hour
      @statuses[:stop_hour]
    end

    def need_start?(today, hour)
      running_day?(today) and start_hour == hour
    end

    def need_stop?(today, hour)
      running_day?(today) and stop_hour == hour
    end

    def running_day?(today)
      case @statuses[:running_day]
      when "all"
        true
      when "weekday"
        today.weekday?
      else
        false
      end
    end

    def stop
      @instance.stop
    end

    def start
      @instance.start
    end

    private
    # Tag "running_period" をパース
    #  value = "all": 常時起動 (default)
    #  value = "working": 勤務時間のみ起動 ("8-22"と同じ)
    #  value = "10-18": 起動時間と停止時間の指定 (数字は0-23)
    def parse_running_period(value)
      case value 
      when nil, "", "all"
        ["-", "-"]
      when "working"
        ["8", "22"]
      when /(\d{,2})-(\d{,2})/
        [$1, $2]
      else
        raise "unknown tag value 'running_period=#{value}'"
      end
    end

    # Tag "running_day" をパース
    #  value = "all": 常時起動(default)
    #  value = "weekday": 平日のみ起動
    def parse_running_day(value)
      case value 
      when nil, "", "all", "weekday"
        value
      else
        raise "unknown tag value 'running_day=#{value}'"
      end
    end

    def get_statuses(tags)
      name = tags["Name"]
      begin
        start_hour, stop_hour = parse_running_period(tags["running_period"])
        running_day = parse_running_day(tags["running_day"])
        elastic_ip = tags["elastic_ip"]

        {
          name: name,
          start_hour: start_hour,
          stop_hour: stop_hour,
          running_day: running_day,
          elastic_ip: elastic_ip,
        }
      rescue => e
        {
          name: name,
          error: e.message
        }
      end
    end
  end
end


