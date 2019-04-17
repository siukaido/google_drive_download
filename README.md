# google_drive_download

- 確認した環境

```
$ ruby -v
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-darwin18]
```

使い方

```
$ bundle install
$ cp config.tpl.json config.json
$ vi config.json
$ ruby run.ruby https://drive.google.com/drive/folders/XXXXXXXXXXXXX ~/Downloads
```
