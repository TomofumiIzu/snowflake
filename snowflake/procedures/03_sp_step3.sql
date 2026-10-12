-- =============================================================================
-- STEP3: STEP1_RAW / STEP2_CLEANED の累計件数を STEP3_SUMMARY に INSERT
-- =============================================================================
CREATE OR REPLACE PROCEDURE {{DATABASE}}.{{SCHEMA}}.SP_STEP3(RUN_ID VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    v_step1 NUMBER;
    v_step2 NUMBER;
BEGIN
    SELECT COUNT(*) INTO :v_step1 FROM STEP1_RAW;
    SELECT COUNT(*) INTO :v_step2 FROM STEP2_CLEANED;

    INSERT INTO STEP3_SUMMARY (RUN_ID, STEP1_COUNT, STEP2_COUNT, INSERTED_AT)
    SELECT :RUN_ID, :v_step1, :v_step2,
           CONVERT_TIMEZONE('Asia/Tokyo', CURRENT_TIMESTAMP())::TIMESTAMP_NTZ;

    RETURN 'SP_STEP3 OK: step1=' || v_step1 || ', step2=' || v_step2 || ', run_id=' || RUN_ID;
END;
$$;
