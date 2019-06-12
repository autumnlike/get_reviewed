#! /usr/bin/env ruby

require 'octokit'
require "pry" # 開発用

# 仕様
# レビュー済みの一覧を取得したい
# レビュー済みの判定が明確にない（用に見える）ので、
# `requested_reviewers` が 空 `empty?` であればレビュー済みとする
# しかし、この値は、レビュアの未アサイン OR レビュー完了 の場合に空になるため、
# PRタイトルに、[WIP/wip] [IR/ir] が無いものとする
#
# ruby ./get_reviewed.rb <token> <repository_name> <label>

if ARGV.count != 3
  puts "引数が違います"
  puts "ruby ./get_reviewed.rb <token> <repository_name> <label>"
  puts "ex: ruby ./get_reviewed.rb tokentokentoken username/repository_name label_name"
  exit
end

token = ARGV[0]
repository = ARGV[1]
label_name = ARGV[2]

client = Octokit::Client.new(access_token: token)
client.auto_paginate = true
client.pull_requests(repository).each do |pr|
  pr.rels[:issue].get.data.rels[:labels].get.data.each do |label|
    if label[:name] == label_name
      next if pr.title.include?("[WIP]")
      next if pr.title.include?("[wip]")
      next if pr.title.include?("[IR]")
      next if pr.title.include?("[ir]")

      # レビュアがいない = レビュー済み OR 未アサイン
      puts "#{pr[:title]}\n#{pr[:html_url]}" if pr[:requested_reviewers].empty?
    end
  end
end
