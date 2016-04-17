# coding: utf-8
require 'yaml'
require 'rake/clean'

# target: デプロイ先ディレクトリを指定。/で終わること
config = YAML.load_file('./conf/rake-config.yml')

desc '次のタスクを実行 [:cp]'
task :default => [:cp]

SRC = FileList['**/*.*']
DIST = FileList.new
config["target"].each do |target_dir|
  DIST.include(SRC.sub(/^/, target_dir + 'LanSend/'))
end
CLEAN.include(DIST)

desc 'windowerにデプロイする'
task :cp => DIST
config["target"].each do |target_dir|
  rule(Regexp.new(target_dir + "LanSend/.*\..*$") => [
    proc {|taskname| taskname.sub(target_dir + "LanSend/", "")}
  ]) do |t|
    mkdir_p t.name.pathmap('%d')
    cp t.source, t.name
  end
end
