"""snowflake/ 配下の SQL を指定環境のスキーマへデプロイする。

使い方:
    python scripts/deploy.py dev    # GHA_DEMO_DB.DEV へデプロイ
    python scripts/deploy.py stg
    python scripts/deploy.py pro

SQL 内の {{DATABASE}} / {{SCHEMA}} を置換し、以下の順にファイル名順で実行する:
    snowflake/setup -> snowflake/tables -> snowflake/procedures
"""

import sys
from pathlib import Path

from sf_conn import connect, database, schema_for

ROOT = Path(__file__).resolve().parent.parent / "snowflake"
ORDER = ["setup", "tables", "procedures"]


def render(sql: str, schema: str) -> str:
    return sql.replace("{{DATABASE}}", database()).replace("{{SCHEMA}}", schema)


def main(env: str) -> None:
    schema = schema_for(env)
    print(f"=== deploy to {database()}.{schema} ===")
    with connect() as conn:
        for folder in ORDER:
            for path in sorted((ROOT / folder).glob("*.sql")):
                print(f"-- {path.relative_to(ROOT.parent)}")
                # execute_string は $$ ... $$ 内のセミコロンを考慮して文を分割する
                for cur in conn.execute_string(render(path.read_text(), schema)):
                    print("   ", cur.fetchone())
    print("deploy completed")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit(__doc__)
    main(sys.argv[1])
