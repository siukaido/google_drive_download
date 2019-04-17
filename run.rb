require "bundler/setup"
require "google_drive"
require "color_echo"

CE.pickup("[Failed]", :red).pickup("失敗しました", :red)

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

collection.files.each do |file|
  print file.title + "のダウンロード中..."
  filename = File.join(ARGV[1], file.title)
  begin
    if file.is_a?(GoogleDrive::Spreadsheet)
      file.export_as_file(filename + ".csv", "text/csv")
    else
      file.download_to_file(filename)
    end
    puts "成功!!"
  rescue => e
    puts "失敗しました"
    p e
  end
end
