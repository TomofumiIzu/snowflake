"""Snowflake 接続の共通処理（ローカル / GitHub Actions 共通）。

認証はキーペア方式。以下のどちらかで秘密鍵を渡す:
  - SNOWFLAKE_PRIVATE_KEY      : 秘密鍵(PEM)の中身そのもの（GitHub Secrets 用）
  - SNOWFLAKE_PRIVATE_KEY_FILE : 秘密鍵ファイルのパス（ローカル用）
"""

import os

import snowflake.connector
from cryptography.hazmat.primitives import serialization

ENVS = {"dev": "DEV", "stg": "STG", "pro": "PRO"}


def database() -> str:
    return os.getenv("SNOWFLAKE_DATABASE", "GHA_DEMO_DB")


def schema_for(env: str) -> str:
    try:
        return ENVS[env.lower()]
    except KeyError:
        raise SystemExit(f"env は {list(ENVS)} のいずれかを指定してください: {env}")


def _load_private_key() -> bytes:
    pem = os.getenv("SNOWFLAKE_PRIVATE_KEY")
    if not pem:
        with open(os.environ["SNOWFLAKE_PRIVATE_KEY_FILE"], "rb") as f:
            pem = f.read().decode()
    passphrase = os.getenv("SNOWFLAKE_PRIVATE_KEY_PASSPHRASE")
    key = serialization.load_pem_private_key(
        pem.encode(), password=passphrase.encode() if passphrase else None
    )
    return key.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )


def connect(schema: str | None = None) -> snowflake.connector.SnowflakeConnection:
    params = {
        "account": os.environ["SNOWFLAKE_ACCOUNT"],
        "user": os.environ["SNOWFLAKE_USER"],
        "role": os.getenv("SNOWFLAKE_ROLE"),
        "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
        "private_key": _load_private_key(),
    }
    conn = snowflake.connector.connect(**{k: v for k, v in params.items() if v})
    if schema:
        # プロシージャ内のテーブル名はスキーマ修飾していないため、実行スキーマを切り替える
        conn.cursor().execute(f"USE SCHEMA {database()}.{schema}")
    return conn
