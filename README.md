# 概要

レビュー済みのプルリクエストを取得します。

# セットアップ

    bundle install --path=/path/to/get_reviewed

# 前提

プルリクエストのタイトルで、[WIP], [IR] の運用前提です。

- WIP: 開発中
- IR: レビュー中
- なし: レビュー完了でリリース可能

# 実行

    ruby ./get_reviewed.rb <github_token> <repository_name> <label_name>
