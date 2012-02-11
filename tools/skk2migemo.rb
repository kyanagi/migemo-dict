#!/usr/bin/env ruby
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
  key.gsub!(/[a-z]\z/, '')
  value.gsub!(%r!\A/|/\z!, '')
  values = value.split('/').map{|v| v.sub(/;.*\z/, '') }.reject{|v| have_number && v =~ /#/ }.reject{|v| v =~ /\A\([a-zA-Z].*\)\z/ }
  if key != '' && values.size > 0
    dict[key.downcase] += values
  end
end

keys = dict.keys.sort_by{|e| [-e.length, e] }
keys.each do |key|
  print "%s\t%s\n" % [key, dict[key].uniq.join("\t")]
end
