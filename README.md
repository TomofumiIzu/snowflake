# snowflake

GitHub Actions で Snowflake へのデプロイと、プロシージャの順次実行を行うサンプル。

## 構成

```
snowflake/
  setup/00_database_schemas.sql   DB (GHA_DEMO_DB) と DEV / STG / PRO スキーマ
  tables/01_tables.sql            STEP1_RAW / STEP2_CLEANED / STEP3_SUMMARY
  procedures/01_sp_step1.sql      SP_STEP1: STEP1_RAW に 1 行 INSERT
  procedures/02_sp_step2.sql      SP_STEP2: STEP1_RAW を加工して STEP2_CLEANED に INSERT
  procedures/03_sp_step3.sql      SP_STEP3: 件数を集計して STEP3_SUMMARY に INSERT
scripts/
  deploy.py                       SQL を環境スキーマへデプロイ（{{DATABASE}} / {{SCHEMA}} を置換）
  call_procedure.py               プロシージャを 1 つ CALL
.github/workflows/
  deploy.yml                      main への push で DEV -> STG -> PRO にデプロイ（手動実行も可）
  run_procedures.yml              毎日 11:00 JST に STG / PRO で SP_STEP1 -> 2 -> 3 を実行（手動実行も可）
```

## GitHub の設定

Settings > Secrets and variables > Actions に以下の Repository secrets を登録する。

| Secret | 例 |
| --- | --- |
| `SNOWFLAKE_ACCOUNT` | `orgname-accountname` |
| `SNOWFLAKE_USER` | `your_user` |
| `SNOWFLAKE_ROLE` | `ACCOUNTADMIN` |
| `SNOWFLAKE_WAREHOUSE` | `COMPUTE_WH` |
| `SNOWFLAKE_PRIVATE_KEY` | 秘密鍵 `rsa_key.p8` の中身（`-----BEGIN PRIVATE KEY-----` から末尾まで） |
| `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE` | 鍵にパスフレーズがある場合のみ |

DB 名を変えたい場合は Variables に `SNOWFLAKE_DATABASE` を登録する（未設定時は `GHA_DEMO_DB`）。

PRO デプロイ前に承認を入れたい場合は Settings > Environments > `pro` に Required reviewers を設定する。

## ローカル実行

```bash
pip install -r requirements.txt
export SNOWFLAKE_ACCOUNT=... SNOWFLAKE_USER=... SNOWFLAKE_ROLE=... SNOWFLAKE_WAREHOUSE=...
export SNOWFLAKE_PRIVATE_KEY_FILE=~/.snowflake/rsa_key.p8

python scripts/deploy.py dev
python scripts/call_procedure.py dev SP_STEP1 test-1
python scripts/call_procedure.py dev SP_STEP2 test-1
python scripts/call_procedure.py dev SP_STEP3 test-1
```

## 確認用クエリ

```sql
SELECT * FROM GHA_DEMO_DB.STG.STEP1_RAW     ORDER BY INSERTED_AT DESC;
SELECT * FROM GHA_DEMO_DB.STG.STEP2_CLEANED ORDER BY INSERTED_AT DESC;
SELECT * FROM GHA_DEMO_DB.STG.STEP3_SUMMARY ORDER BY INSERTED_AT DESC;
```
