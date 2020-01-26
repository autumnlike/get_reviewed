#! /usr/bin/env ruby

require 'octokit'
require "pry" # 開発用
require "csv"

# 仕様
# master にマージされた Pull Request の CSV を生成
#
# @param 0 token: github トークン
# @param 1 repository: リポジトリ
# @param 2 from: 集計開始日
# @param 3 to: 集計終了日
# @param 4 label: 集計するラベル名
# @param 5 ignore_labels: 除外ラベル名(カンマ区切り)
#
# ruby ./get_pull_request_csv.rb <token> <repository_name> <from> <to> <label> <ignore_labels>

if ARGV.count != 5 && ARGV.count != 6
  puts "引数が違います"
  puts "ruby ./get_reviewed.rb <token> <repository_name> <from> <to> <label> <ignore_labels>"
  puts "ex: ruby ./get_reviewed.rb tokentokentoken username/repository_name 2019-10-01 2020-01-01 label_name"
  puts "ex: ruby ./get_reviewed.rb tokentokentoken username/repository_name 2019-10-01 2020-01-01 label_name 'ignore1, ignore2'"
  exit
end

token = ARGV[0]
repository = ARGV[1]
from = Time.parse ARGV[2]
to = Time.parse ARGV[3]
label_name = ARGV[4]
ignore_labels = []
ignore_labels = ARGV[5].split(',') unless ARGV[3].nil?

developers = [
  ['number', 'name', 'created_at', 'merged_at', 'labels']
]
reviewers = [
  ['number', 'name', 'created_at', 'merged_at', 'labels']
]

client = Octokit::Client.new(access_token: token)
client.auto_paginate = true

client.pull_requests(repository, state: 'close', sort: 'updated', direction: 'desc').each do |pr|
  next if !pr.merged_at.nil? && pr.updated_at > to
  break if !pr.merged_at.nil? && pr.updated_at < from

  next unless pr.base.ref == 'master' # マスターマージだけ
  next if pr.merged_at.nil? # マージされてないやつ

  labels = pr.labels.map{ |l| l[:name] }
  next unless labels.include?(label_name) # 対象ラベルが含まれてない
  next if ignore_labels.any? { |il| labels.include? il } # 除外ラベルが含まれる

  # 開発者集計
  developers << [
    pr.number,
    pr.user.login,
    pr.created_at,
    pr.merged_at,
    labels
  ]

  # レビュア集計
  this_roop_reviewed = []
  client.pull_request_reviews(repository, pr.number).each do |rev|
    next unless rev.state == 'APPROVED'
    next if this_roop_reviewed.include? rev.user.login # すでにレビューカウント済み
    this_roop_reviewed << rev.user.login
    reviewers << [
      pr.number,
      rev.user.login,
      pr.created_at,
      pr.merged_at,
      labels
    ]
  end
end

csv = CSV.open('tmp/developer_' + Time.now.strftime('%Y%m%d') + '.csv','w')
developers.each { |r| csv.puts r }
csv.close

csv = CSV.open('tmp/reviewer_' + Time.now.strftime('%Y%m%d') + '.csv','w')
reviewers.each { |r| csv.puts r }
csv.close
