-- =============================================================================
-- STEP2: 同じ RUN_ID の STEP1_RAW を加工して STEP2_CLEANED に INSERT
--   STEP1 が未実行（対象行 0 件）ならエラーにしてワークフローを止める
-- =============================================================================
CREATE OR REPLACE PROCEDURE {{DATABASE}}.{{SCHEMA}}.SP_STEP2(RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    v_rows      NUMBER DEFAULT 0;
    no_source   EXCEPTION (-20002, 'STEP1_RAW に対象 RUN_ID の行がありません');
BEGIN
    INSERT INTO STEP2_CLEANED (RUN_ID, MESSAGE_UPPER, MESSAGE_LEN, INSERTED_AT)
    SELECT RUN_ID,
           UPPER(MESSAGE),
           LENGTH(MESSAGE),
           CONVERT_TIMEZONE('Asia/Tokyo', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ
    FROM STEP1_RAW
    WHERE RUN_ID = :RUN_ID;

    v_rows := SQLROWCOUNT;
    IF (v_rows = 0) THEN
        RAISE no_source;
    END IF;

    RETURN 'SP_STEP2 OK: ' || v_rows || ' rows, run_id=' || RUN_ID;
END;
$$;
