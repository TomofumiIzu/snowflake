-- =============================================================================
-- 初期セットアップ: データベースと環境別スキーマ（DEV / STG / PRO）を作成
--   deploy.py の実行時に毎回流れるが IF NOT EXISTS なので何度実行しても安全
-- =============================================================================
CREATE DATABASE IF NOT EXISTS {{DATABASE}};

CREATE SCHEMA IF NOT EXISTS {{DATABASE}}.DEV COMMENT = '開発環境';
CREATE SCHEMA IF NOT EXISTS {{DATABASE}}.STG COMMENT = 'ステージング環境';
CREATE SCHEMA IF NOT EXISTS {{DATABASE}}.PRO COMMENT = '本番環境';
