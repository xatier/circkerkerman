# circ kerkerman bot #

[噗浪](http://www.plurk.com) 機器人CIRC 科科人是我高三時開始做的作品

原本是用 Plurk API 1.0 in C + Perl 詞庫分析做成的 (那時候 C API lib 還很多功能沒完全，還有自己補完需要的功能 囧rz)

大一下修 NA 時的 Perl programming 作業用 APP 2.0 拓展/重寫了原本的 C API 部份，全程式用 Perl 完成

近日(大二上某天晚上的單人 hackathon ) 把架構大改過，換成聽 channel 的方式抓噗，並新增了一些功能



## functoins ##

### Dictionary ###

`%Dict%:word` 查 ydict 字典

### date ###

`%Date%` 查詢日期

### Calculator ###

`%Cals%:expressoin` 簡單的計算機功能

### Youtube search ###

`想聽 XXX` Youtube 歌曲搜尋

### random reply ###

額外的關鍵字回噗功能，按照 db 文字檔定義的回應


## files ##

### plurk.pl ###

目前機器人工作中的版本

### plurk.pl.oldversion ###

大一下寫的版本，有點亂 (艸)

###  plurk.py  rep.py ###

兩個官方的 python 範例，目前 circkerkerman 每三小時的報時是透過 plurk.py + crontab 完成

### db ###

回噗詞庫
