# 概要

レビュー済みのプルリクエストを取得します。

# セットアップ

    bundle install --path=/path/to/github_ruby_api

# 使い方

## get_pullrequest_csv

指定ラベル の プルリクエストをCSVにする

```
$ ruby ./get_pull_request_csv.rb <token> <repository_name> <from> <to> <label> <ignore_labels>
```

## get_reviewed 

レビュー済みのプルリクエストを取得

### 前提

プルリクエストのタイトルで、[WIP], [IR] の運用前提です。

- WIP: 開発中
- IR: レビュー中
- なし: レビュー完了でリリース可能

### 実行

    ruby ./get_reviewed.rb <github_token> <repository_name> <label_name>
