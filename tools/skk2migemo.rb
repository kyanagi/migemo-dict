#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# usage: skk2migemo.rb SKK-JISYO.JIS3_4 > migemo-dict.jis3_4
require 'iconv'
dict = Hash.new{[]}
ARGF.each_line do |line|
  line.chomp!
  line = Iconv.conv('UTF-8', 'EUC-JISX0213', line)
  next if line =~ /\A;/
  if line =~ /\A([^ ]+) +(.*)\z/
    key, value = $1, $2
  end
  next if !key || key == ''
  next if key =~ /(\A[<>?]|[<>?]\z)/

  have_number = key =~ /#/

  # 送りを削除
  key.sub!(/(.*[\p{Hiragana}\p{Katakana}ー])[a-z]\z/){ $1 }

  value.gsub!(%r!\A/|/\z!, '')
  values = value.split('/').map{ |v| v.sub(/;.*\z/, '') }.
    reject{|v| have_number && v =~ /#/ }.
    reject{|v| v =~ /\A\([a-zA-Z].*\)\z/ }. # S-exp
    reject{|v| v =~ /\A[-a-z ]+\z/i }

  # アルファベットキーのものは原則として削除。
  # ただし変換先が1文字のものは残す。
  if key =~ /[a-z]/i
    # 合字を考慮
    values.keep_if{|v| v.size == 1 || (v.size == 2 && v !~ /\A[\p{Han}\p{Hiragana}\p{Katakana}ー]+\z/) }
  end

  if key != '' && values.size > 0
    dict[key.downcase] += values
  end
end

keys = dict.keys.sort_by{|e| [-e.length, e] }
keys.each do |key|
  print "%s\t%s\n" % [key, dict[key].uniq.join("\t")]
end
