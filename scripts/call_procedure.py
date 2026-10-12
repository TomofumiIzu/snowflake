"""指定環境のプロシージャを 1 つ CALL する。失敗時は終了コード 1 を返す。

使い方:
    python scripts/call_procedure.py <env> <procedure> <run_id>
    例) python scripts/call_procedure.py stg SP_STEP1 12345
"""

import re
import sys

from sf_conn import connect, schema_for


def main(env: str, procedure: str, run_id: str) -> None:
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", procedure):
        raise SystemExit(f"不正なプロシージャ名です: {procedure}")
    with connect(schema_for(env)) as conn, conn.cursor() as cur:
        cur.execute(f"CALL {procedure}(%s)", (run_id,))
        print(cur.fetchone()[0])


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit(__doc__)
    main(*sys.argv[1:])
