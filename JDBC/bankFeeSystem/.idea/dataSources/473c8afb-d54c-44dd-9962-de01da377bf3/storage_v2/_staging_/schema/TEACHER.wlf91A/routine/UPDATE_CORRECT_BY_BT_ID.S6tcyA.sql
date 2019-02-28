create PROCEDURE UPDATE_CORRECT_BY_BT_ID(IN_BT_ID IN BANK_TRANSFER_RECORD.BT_ID%TYPE,
                                           IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,
                                           OUT_RES OUT VARCHAR2) AS
  bank_id_           BANK_TRANSFER_RECORD.BANK_ID%TYPE;
  card_id_           BANK_TRANSFER_RECORD.CARD_ID%TYPE;
  transfer_amount_   BANK_TRANSFER_RECORD.TRANSFER_AMOUNT%TYPE;
  transfer_time_     BANK_TRANSFER_RECORD.TRANSFER_TIME%TYPE := NULL;
  correct_can        NUMBER;
  pay_type_          PAY_LOG.PAY_TYPE%TYPE;
  pay_state_         POWER_RATE_LIST.PAY_STATE%TYPE;
  pay_id_            PAY_LOG.PAY_ID%TYPE := NULL;
  notes_             PAY_LOG.NOTES%TYPE;
  notes_temp         PAY_LOG.NOTES%TYPE;
  pr_id_             POWER_RATE_LIST.PR_ID%TYPE := NULL;
  fee_               PAY_LOG.PAY_AMOUNT%TYPE;
  already_fee_       POWER_RATE_LIST.ALREADY_FEE%TYPE;
  pay_time_          PAY_LOG.PAY_TIME%TYPE;   -- 上一付费时间
  fee_sum            PAY_LOG.PAY_AMOUNT%TYPE := 0;
  index1             NUMBER := 0;
  index2             NUMBER := 0;
  length             NUMBER := 0;
  BEGIN
    --判断流水号是否存在
    BEGIN
    SELECT BANK_ID,CARD_ID,TRANSFER_AMOUNT,TRANSFER_TIME INTO bank_id_,card_id_,transfer_amount_,transfer_time_
    FROM BANK_TRANSFER_RECORD
    WHERE BT_ID = IN_BT_ID AND CUSTOMER_ID = IN_CUSTOMER_ID;

    --判断是否为可冲正的时间
    correct_can := TO_DATE(SYSDATE) - TO_DATE(transfer_time_);
    IF correct_can != 0
      THEN
          --OUT_RESPONSE := '流水号为' || IN_BT_ID || '的转账记录，转账时间为' || TO_DATE(transfer_time_,'yyyy-mm-dd hh24:mi:ss') ||  '，超过可冲正时间';
          DBMS_OUTPUT.PUT_LINE('[ERROR]流水号为' || IN_BT_ID || '的转账记录，转账时间为' || TO_CHAR(transfer_time_,'yyyy-mm-dd hh24:mi:ss') ||  '，超过可冲正时间');
          OUT_RES := '[ERROR]流水号为' || IN_BT_ID || '的转账记录，转账时间为' || TO_CHAR(transfer_time_,'yyyy-mm-dd hh24:mi:ss') ||  '，超过可冲正时间';
    ELSIF correct_can = 0
      THEN
          BEGIN
            SELECT PAY_ID,PAY_TYPE,NOTES INTO pay_id_,pay_type_,notes_ FROM PAY_LOG WHERE BT_ID = IN_BT_ID AND PAY_TYPE = '01';
            --插入冲正记录并更新原纪录
            INSERT INTO PAY_LOG (CUSTOMER_ID,PAY_TIME,PAY_AMOUNT,PAY_TYPE,BANK_ID,BT_ID,NOTES) VALUES (IN_CUSTOMER_ID,SYSDATE,transfer_amount_,'02',bank_id_,IN_BT_ID,'冲正记录');
            UPDATE PAY_LOG SET PAY_TYPE = '03' WHERE PAY_ID = pay_id_;
            --修改电费清单
            LOOP
              EXIT WHEN notes_ IS NULL;
              index1 := INSTR(notes_,';');
              length := index1 - 1;
              notes_temp := SUBSTR(notes_,1,length);
              notes_ := SUBSTR(notes_,index1+1);
              index2 := INSTR(notes_temp,',');
              length := index2 - 1;
              pr_id_ := TO_NUMBER(SUBSTR(notes_temp,1,length));
              fee_ := TO_NUMBER(SUBSTR(notes_temp,index2+1));
              fee_sum := fee_sum + fee_;
              --更新电费清单
              SELECT ALREADY_FEE,MT_DATE INTO already_fee_,pay_time_ FROM POWER_RATE_LIST WHERE PR_ID = pr_id_;
              IF already_fee_ > fee_
              THEN
                pay_state_ := '2';
                --找到上一缴费时间
                BEGIN
                  SELECT PAY_TIME INTO pay_time_ FROM PAY_LOG
                  WHERE NOTES like '%' || to_char(pr_id_) || '%' AND ROWNUM = 1 AND BT_ID != IN_BT_ID ORDER BY PAY_TIME DESC;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                    --说明是抄表时的自动扣费
                      NULL;
                END;
              ELSE
                pay_state_ := '0';
                pay_time_ := NULL;
              END IF;
              UPDATE POWER_RATE_LIST
              SET ALREADY_FEE = ALREADY_FEE - fee_,
                  PAY_DATE = pay_time_,
                  PAY_STATE = pay_state_
              WHERE PR_ID = pr_id_;
              DBMS_OUTPUT.PUT_LINE('[SUCCESS]已成功还原编号为' || pr_id_ || '电费清单');
            END LOOP;
            --修改用户余额
            UPDATE CUSTOMER SET BALANCE = BALANCE + fee_sum WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
            INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PAY_ID, BT_ID) VALUES (IN_CUSTOMER_ID,'3',fee_sum,pay_id_,IN_BT_ID);
            DBMS_OUTPUT.PUT_LINE('[SUCCESS]已成功将编号为' || pay_id_ || '缴费记录更新为已冲正');
            OUT_RES := OUT_RES || '[SUCCESS]已成功将编号为' || pay_id_ || '缴费记录更新为已冲正';
            DBMS_OUTPUT.PUT_LINE('[SUCCESS]已成功将冲正所得的' || fee_sum || '元转入余额');
            OUT_RES := OUT_RES || '[SUCCESS]已成功将冲正所得的' || fee_sum || '元转入余额';
            COMMIT;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('[ERROR]没有找到与流水号为' || IN_BT_ID || '的转账记录对应的未冲正缴费日志');
            OUT_RES := '[ERROR]没有找到与流水号为' || IN_BT_ID || '的转账记录对应的未冲正缴费日志';
          END;
    END IF;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN  -- 捕捉到 NO_DATA_FOUND 异常
        DBMS_OUTPUT.PUT_LINE('[ERROR]未找到流水号为' || IN_BT_ID || '的记录或该记录与您的客户ID不一致');
        OUT_RES := '[ERROR]未找到流水号为' || IN_BT_ID || '的记录或该记录与您的客户ID不一致';
    END;
  END UPDATE_CORRECT_BY_BT_ID;
/

