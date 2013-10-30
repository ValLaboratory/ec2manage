require "ec2manage/version"
require "ec2manage/instance"
require "aws-sdk"

module Ec2manage
  module Logging
    def log(level, message)
      $stderr.puts "#{DateTime.now.strftime("%Y/%m/%d %H:%M:%S.%L")} [#{level}] #{message}"
    end
  end

  EC2_ENDPOINT = 'ec2.ap-northeast-1.amazonaws.com'

  class App
    include Ec2manage::Logging

    def initialize
      AWS::config(
        access_key_id: ENV["ACCESS_KEY_ID"],
        secret_access_key: ENV["SECRET_ACCESS_KEY"],
        proxy_uri: ENV["http_proxy"],
      )

      @ec2 = AWS::EC2.new(ec2_endpoint: EC2_ENDPOINT)
    end

    def dry_run(today, hour)
      on_start = lambda{|instance|
        log :INFO, "start(dry) '#{instance.name}(#{instance.id})'"
      }
      on_stop = lambda{|instance|
        log :INFO, "stop(dry) '#{instance.name}(#{instance.id})'"
      }
      on_no_action = lambda{|instance|
        log :INFO, "pass '#{instance.name}(#{instance.id})'"
      }
      on_error = lambda{|instance|
        log :WARN, "#{instance.error} '#{instance.name}(#{instance.id})'"
      }

      run(today, hour, on_start, on_stop, on_no_action, on_error)
    end

    def exec(today, hour)
      on_start = lambda{|instance|
        log :INFO, "start '#{instance.name}(#{instance.id})'"
        instance.start 
      }
      on_stop = lambda{|instance|
        log :INFO, "stop '#{instance.name}(#{instance.id})'"
        instance.stop 
      }
      on_no_action = lambda{|instance|
        log :INFO, "pass '#{instance.name}(#{instance.id})'"
      }
      on_error = lambda{|instance|
        log :WARN, "#{instance.error} '#{instance.name}(#{instance.id})'"
      }

      run(today, hour, on_start, on_stop, on_no_action, on_error)
    end

    private
    def run(today, hour, on_start, on_stop, on_no_action, on_error)
      instances = @ec2.instances.lazy.map{|i| Instance.new(i)}
      
      instances.each do |instance|
        unless instance.good?
          on_error[instance]
          next
        end

        if instance.need_start?(today, hour)
          on_start[instance]
        elsif instance.need_stop?(today, hour)
          on_stop[instance]
        else
          on_no_action[instance]
        end
      end
    end
  end

  module_function
  def dry_run(hour)
    App.new.dry_run(Date.today, hour)
  end
  def exec(hour)
    App.new.exec(Date.today, hour)
  end
  def start
    puts "unimplemented"
  end
  def stop
    puts "unimplemented"
  end
  def volume_cleanup
    puts "unimplemented"
  end
end
