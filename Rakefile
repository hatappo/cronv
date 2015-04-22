
desc "デモします。"
task :demo do
  require "./cron_v"

  # cron設定のサンプル。３行。
  sample_cron = [
    "5-9,6,*/12 */2 * * * echo 123 > ~/foo.txt 2>&1",
    "*/5        */4 * * * echo 456 > ~/bar.txt 2>&1",
    "5,10,15      * * * * echo 789 > ~/baz.txt 2>&1"
                ].join ?\n
  puts
  puts "---------- sample crontab settings."
  puts sample_cron
  puts "----------"
  puts "このcrontab設定で現在時から４時間の間に実行されるコマンドをタイムライン表示します。"
  puts

  sleep 2

  # 実行
  hours = 4
  puts "exec: cron_timeline_diagram = Crontav::Visualizer.new(sample_cron).show(60 * 60 * #{hours})"
  puts Crontav::Visualizer.new(sample_cron).show(60 * 60 * hours)
end
