-- =============================================================================
-- STEP1: STEP1_RAW に 1 行 INSERT
-- =============================================================================
CREATE OR REPLACE PROCEDURE {{DATABASE}}.{{SCHEMA}}.SP_STEP1(RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
    INSERT INTO STEP1_RAW (RUN_ID, MESSAGE, INSERTED_AT)
    SELECT :RUN_ID,
           'hello from ' || CURRENT_SCHEMA(),
           CONVERT_TIMEZONE('Asia/Tokyo', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ;

    RETURN 'SP_STEP1 OK: run_id=' || RUN_ID;
END;
$$;
