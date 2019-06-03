require "bundler/setup"
require "google_drive"
require "color_echo"
require "parallel"
require "optparse";

THREAD_COUNT = 1

def usage
  puts "Usage: ruby run.rb [OPTION]... <SourceURL> <DistPath>"
  puts
  puts "Mandatory arguments to long options are mandatory for short options too."
  puts "  --name  SourceURL直下で対応するファイル/ディレクトリ名"
  puts "  -h      ヘルプ表示"
end

def download(basepath, file)
  filename = File.join(basepath, file.title)
  begin
    if file.is_a?(GoogleDrive::Collection)
      Dir.mkdir(filename) unless Dir.exist?(filename)
      Parallel.each(file.files, in_threads: THREAD_COUNT) do |file|
        download(filename, file)
      end
    else
      puts "[Start] " + file.title
      if file.is_a?(GoogleDrive::Spreadsheet)
        filename += ".csv"
        file.export_as_file(filename, "text/csv")
      else
        file.download_to_file(filename)
      end
    end
    puts "[Successful] Copy " + sprintf("%-20s", file.title) + "\t -> " + filename
  rescue => e
    puts "[Failed] " + file.title + " のダウンロードに失敗しました"
    p e
  end
  return filename
end

CE.pickup("[Failed]", :red).pickup("[Successful]", :h_blue)
params = ARGV.getopts("h", "name:")

if params["h"]
  usage
  exit
end

unless ARGV[0]
  puts "[Failed] URLをいれてください"
  usage
  exit 1
end
unless ARGV[1]
  puts "[Failed] 保存先のディレクトリを指定してください"
  usage
  exit 1
end

session = GoogleDrive::Session.from_config("config.json")
begin
  collection = session.collection_by_url(ARGV[0])
rescue => e
  puts "[Failed] 指定URLのドライブにアクセスできません"
  exit 1
end

Parallel.each(collection.files, in_threads: THREAD_COUNT) do |file|
  if params["name"]
    next unless file.title.match(params["name"])
  end

  download(ARGV[1], file)
end
