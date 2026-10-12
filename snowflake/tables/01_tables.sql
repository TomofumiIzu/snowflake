-- =============================================================================
-- テーブル定義（{{SCHEMA}} はデプロイ先の環境スキーマに置換される）
--   STEP1_RAW     : SP_STEP1 が 1 行 INSERT
--   STEP2_CLEANED : SP_STEP2 が STEP1_RAW の行を加工して INSERT
--   STEP3_SUMMARY : SP_STEP3 が STEP2_CLEANED を集計して INSERT
-- =============================================================================
CREATE TABLE IF NOT EXISTS {{DATABASE}}.{{SCHEMA}}.STEP1_RAW (
    RUN_ID      VARCHAR       NOT NULL COMMENT '実行ID（GitHub Actions の run_id など）',
    MESSAGE     VARCHAR                COMMENT '任意メッセージ',
    INSERTED_AT TIMESTAMP_NTZ NOT NULL COMMENT '登録日時（日本時間）'
);

CREATE TABLE IF NOT EXISTS {{DATABASE}}.{{SCHEMA}}.STEP2_CLEANED (
    RUN_ID        VARCHAR       NOT NULL COMMENT '実行ID',
    MESSAGE_UPPER VARCHAR                COMMENT 'MESSAGE を大文字化したもの',
    MESSAGE_LEN   NUMBER(38,0)           COMMENT 'MESSAGE の文字数',
    INSERTED_AT   TIMESTAMP_NTZ NOT NULL COMMENT '登録日時（日本時間）'
);

CREATE TABLE IF NOT EXISTS {{DATABASE}}.{{SCHEMA}}.STEP3_SUMMARY (
    RUN_ID       VARCHAR       NOT NULL COMMENT '実行ID',
    STEP1_COUNT  NUMBER(38,0)  NOT NULL COMMENT 'STEP1_RAW の累計件数',
    STEP2_COUNT  NUMBER(38,0)  NOT NULL COMMENT 'STEP2_CLEANED の累計件数',
    INSERTED_AT  TIMESTAMP_NTZ NOT NULL COMMENT '登録日時（日本時間）'
);
