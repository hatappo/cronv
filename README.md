visualize crontab settings.

`rake demo`

```sh
$ rake demo

---------- sample crontab settings.
6-10,7,*/6 */4 * * * echo 123 > ~/foo.txt 2>&1
8,9,10     */8 * * * echo 456 > ~/bar.txt 2>&1
10,20        * * * * echo 789 > ~/baz.txt 2>&1
----------
このcrontab設定で現在時から三時間の間に実行されるコマンドをタイムライン表示します。

exec: cron_timeline_diagram = Crontav::Visualizer.new(sample_cron).show(60 * 60 * 3)
 ┏━━━ 2015-04-23 00:48:00 +0900. Displaying from.
 ┣━━━ 2015-04-23 00:48:00 +0900 -> echo 123 > ~/foo.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 00:54:00 +0900 -> echo 123 > ~/foo.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 01:10:00 +0900 -> echo 789 > ~/baz.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 01:20:00 +0900 -> echo 789 > ~/baz.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 02:10:00 +0900 -> echo 789 > ~/baz.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 02:20:00 +0900 -> echo 789 > ~/baz.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 03:10:00 +0900 -> echo 789 > ~/baz.txt 2>&1
 ・
 ・
 ・
 ┣━━━ 2015-04-23 03:20:00 +0900 -> echo 789 > ~/baz.txt 2>&1
 ・
 ・
 ・
 ┗━━━ 2015-04-23 03:49:00 +0900 Displayed to.
```
