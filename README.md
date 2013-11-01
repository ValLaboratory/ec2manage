# Ec2manage

EC2インスタンスの管理スクリプト.

### ec2manage exec

EC2インスタンスの自動起動・停止.
EC2インスタンスに下記のTagを付けると、時間に応じてStart/Stopを実行する.

- Tag "running_period"
  - "all" (default)
    - 常時起動. StartもStopも実行しない.
  - "working"
    - 勤務時間のみ起動. ("8-22"と同じ設定)  
  - "起動時間-停止時間"
    - 起動時間と停止時間を数値で指定する. (ex. "9-20")
    - 数値は0-23の範囲

- Tag "running_day"
  - "all" (default)
    - 常時起動.
    - 常に"running_period"の設定に応じてStart/Stopを実行する.
  - "weekday"
    - 平日のみ起動.
    - 実行日が月-金の場合のみ"running_period"の設定に応じてStart/Stopを実行する.

`ec2manage exec`は下記の環境変数を利用する.

- ACCESS_KEY_ID
- SECRET_ACCESS_KEY
- http_proxy (option)

また、`ec2manage exec`を実行するには下記の権限が必要となる.

- ec2:DescribeTags
- ec2:DescribeInstanceAttribute
- ec2:DescribeInstanceStatus
- ec2:DescribeInstances
- ec2:MonitorInstances
- ec2:StartInstances
- ec2:StopInstances 

### ec2manage volume_cleanup

EBSボリュームの自動削除.
実行すると`available`状態のEBSボリュームを削除する.

`ec2manage volume_cleanup`は下記の環境変数を利用する.

- ACCESS_KEY_ID
- SECRET_ACCESS_KEY
- http_proxy (option)

また、`ec2manage volume_cleanup`を実行するには下記の権限が必要となる.

- ec2:DescribeVolumeAttribute
- ec2:DescribeVolumeStatus
- ec2:DescribeVolumes
- ec2:DeleteVolume

## Installation

Add this line to your application's Gemfile:

    gem 'ec2manage', git: "https://github.com/ValLaboratory/ec2manage.git"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ec2manage

## Usage

see `$ ec2manage help`

## Example
    
- EC2インスタンス
  - Name=A
    - 常時起動
  - Name=B, running_day=all, running_period=all
    - 常時起動
  - Name=C, running_day=all, running_period=working
    - 毎日8時にStart/22時にStop
  - Name=D, running_day=all, running_period=9-22
    - 毎日9時にStart/22時にStop
  - Name=E, running_day=weekday, running_period=working
    - 平日のみ8時にStart/22時にStop
  - Name=F, running_day=weekday, running_period=9-22
    - 平日のみ9時にStart/22時にStop

// 平日(08:00)

```
$ date
2013年 10月30日 水曜日 08時00分28秒 JST
$ ec2manage dry_run 8
2013/10/30 08:00:34.185 [INFO] pass 'A(i-xxxxxxxx)'
2013/10/30 08:00:34.491 [INFO] pass 'B(i-xxxxxxxx)'
2013/10/30 08:00:34.813 [INFO] start(dry) 'C(i-xxxxxxxx)'
2013/10/30 08:00:35.123 [INFO] pass 'D(i-xxxxxxxx)'
2013/10/30 08:00:35.463 [INFO] start(dry) 'E(i-xxxxxxxx)'
2013/10/30 08:00:35.791 [INFO] pass 'F(i-xxxxxxxx)'
```

// 平日(22:00)

```
$ date
2013年 10月30日 水曜日 22時00分28秒 JST
$ ec2manage dry_run 22
2013/10/30 22:00:34.185 [INFO] pass 'A(i-xxxxxxxx)'
2013/10/30 22:00:34.491 [INFO] pass 'B(i-xxxxxxxx)'
2013/10/30 22:00:34.813 [INFO] stop(dry) 'C(i-xxxxxxxx)'
2013/10/30 22:00:35.123 [INFO] stop(dry) 'D(i-xxxxxxxx)'
2013/10/30 22:00:35.463 [INFO] stop(dry) 'E(i-xxxxxxxx)'
2013/10/30 22:00:35.791 [INFO] stop(dry) 'F(i-xxxxxxxx)'
```

// 休日(08:00)

```
$ date
2013年 11月02日 土曜日 08時00分28秒 JST
$ ec2manage exec 8
2013/11/02 08:00:34.185 [INFO] pass 'A(i-xxxxxxxx)'
2013/11/02 08:00:34.491 [INFO] pass 'B(i-xxxxxxxx)'
2013/11/02 08:00:34.813 [INFO] start 'C(i-xxxxxxxx)'
2013/11/02 08:00:35.123 [INFO] pass 'D(i-xxxxxxxx)'
2013/11/02 08:00:35.463 [INFO] pass 'E(i-xxxxxxxx)'
2013/11/02 08:00:35.791 [INFO] pass 'F(i-xxxxxxxx)'
```

// 休日(22:00)

```
$ date
2013年 11月02日 土曜日 22時00分28秒 JST
$ ec2manage exec 22
2013/11/02 22:00:34.185 [INFO] pass 'A(i-xxxxxxxx)'
2013/11/02 22:00:34.491 [INFO] pass 'B(i-xxxxxxxx)'
2013/11/02 22:00:34.813 [INFO] stop 'C(i-xxxxxxxx)'
2013/11/02 22:00:35.123 [INFO] stop 'D(i-xxxxxxxx)'
2013/11/02 22:00:35.463 [INFO] pass 'E(i-xxxxxxxx)'
2013/11/02 22:00:35.791 [INFO] pass 'F(i-xxxxxxxx)'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
