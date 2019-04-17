require "bundler/setup"
require "google_drive"
require "color_echo"
require "parallel"

CE.pickup("[Failed]", :red).pickup("[Successful]", :h_blue)

session = GoogleDrive::Session.from_config("config.json")

unless ARGV[0]
  puts "[Failed] URLをいれてください"
  exit 1
end

unless ARGV[1]
  puts "[Failed] 保存先のディレクトリを指定してください"
  exit 1
end

begin
  collection = session.collection_by_url(ARGV[0])
rescue => e
  puts "[Failed] 指定URLのドライブにアクセスできません"
  exit 1
end

Parallel.each(collection.files, in_threads: 5) do |file|
  filename = File.join(ARGV[1], file.title)
  begin
    if file.is_a?(GoogleDrive::Spreadsheet)
      filename += ".csv"
      file.export_as_file(filename, "text/csv")
    else
      file.download_to_file(filename)
    end
    puts "[Successful] " + file.title + " を " + filename + " にダウンロードしました"
  rescue => e
    puts "[Failed] " + file.title + " のダウンロードに失敗しました"
    p e
  end
end
