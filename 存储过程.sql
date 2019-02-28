--工具类
--新建客户
create PROCEDURE INSERT_NEW_CUSTOMER(IN_CUSTOMER_NAME IN CUSTOMER.CUSTOMER_NAME%TYPE,
                                                   IN_ADDRESS IN CUSTOMER.ADDRESS%TYPE,
                                                   IN_BALANCE IN CUSTOMER.BALANCE%TYPE,
                                                   IN_PSWORD IN CUSTOMER.PSWORD%TYPE) AS
  balance_xiaoyuling          EXCEPTION;
  customer_id_                CUSTOMER.CUSTOMER_ID%TYPE;
  BEGIN
    IF IN_BALANCE < 0 THEN
      RAISE balance_xiaoyuling;
    END IF;
    INSERT INTO CUSTOMER (CUSTOMER_NAME, ADDRESS, BALANCE, PSWORD) VALUES (IN_CUSTOMER_NAME,IN_ADDRESS,IN_BALANCE,IN_PSWORD);
    SELECT CUSTOMER_ID_SEQUENCE.currval INTO customer_id_ from dual;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[SUCCESS]新建用户' || customer_id_ || '成功');
    EXCEPTION WHEN balance_xiaoyuling THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR]新建用户的余额不可小于零');
  END;
/

--新建设备
create PROCEDURE INSERT_NEW_DEVICE(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,
                                                IN_DEVICE_TYPE IN DEVICE.DEVICE_TYPE%TYPE,
                                                IN_DEVICE_NAME IN DEVICE.DEVICE_NAME%TYPE) AS
  in_customer_id_error          EXCEPTION;
  device_type_error          EXCEPTION;
  device_id_                DEVICE.DEVICE_ID%TYPE;
  customer_name_            CUSTOMER.CUSTOMER_NAME%TYPE;
  BEGIN
    BEGIN
      SELECT CUSTOMER_NAME INTO customer_name_ FROM CUSTOMER WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE in_customer_id_error;
    END;
    IF IN_DEVICE_TYPE != '01' AND IN_DEVICE_TYPE != '02' THEN
      RAISE device_type_error;
    END IF;
    INSERT INTO DEVICE (CUSTOMER_ID, DEVICE_TYPE, DEVICE_NAME) VALUES (IN_CUSTOMER_ID,IN_DEVICE_TYPE,IN_DEVICE_NAME);
    SELECT DEVICE_ID_SEQUENCE.currval INTO device_id_ from dual;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[SUCCESS]新建用户' || customer_name_ || '的电表' || device_id_ || '成功');
    EXCEPTION
      WHEN in_customer_id_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]输入用户ID不存在，新建失败');
      WHEN device_type_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]新电表类型异常，新建失败');
  END;
/

--新建银行卡
create PROCEDURE INSERT_NEW_BANK_CARD(IN_BANK_ID IN BANK.BANK_ID%TYPE,
                                                IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE) AS
  in_customer_id_error          EXCEPTION;
  in_bank_id_error              EXCEPTION;
  bank_name_                    BANK.BANK_NAME%TYPE;
  customer_name_                CUSTOMER.CUSTOMER_NAME%TYPE;
  card_id                       BANK_CARD.CARD_ID%TYPE;
  BEGIN
    BEGIN
      SELECT BANK_NAME INTO bank_name_ FROM BANK WHERE BANK_ID = IN_BANK_ID;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE in_bank_id_error;
    END;
    BEGIN
      SELECT CUSTOMER_NAME INTO customer_name_ FROM CUSTOMER WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        RAISE in_customer_id_error;
    END;
    INSERT INTO BANK_CARD (BANK_ID, CUSTOMER_ID) VALUES (IN_BANK_ID,IN_CUSTOMER_ID);
    SELECT CARD_ID_SEQUENCE.currval INTO card_id from dual;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('[SUCCESS]新建用户' || customer_name_ || '的' || bank_name_ || '的银行卡' || card_id || '成功');
    EXCEPTION
      WHEN in_customer_id_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]输入用户ID不存在，新建失败');
      WHEN in_bank_id_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]输入银行ID不存在，新建失败');
  END;
/

--登录验证
create PROCEDURE QUERY_VALIDATE_LOGIN(IN_USER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,
                                                    IN_USER_PASSWORD IN CUSTOMER.PSWORD%TYPE,
                                                    IN_USER_TYPE IN NUMBER,
                                                    OUT_RESULT OUT VARCHAR2,
                                                    OUT_NAME OUT CUSTOMER.CUSTOMER_NAME%TYPE) AS
  BEGIN
    OUT_RESULT := 'WRONG';
    CASE IN_USER_TYPE
      WHEN '1' THEN
        BEGIN
          SELECT CUSTOMER_NAME INTO OUT_NAME FROM CUSTOMER WHERE CUSTOMER_ID = IN_USER_ID AND PSWORD = IN_USER_PASSWORD;
          OUT_RESULT := 'RIGHT';
          EXCEPTION WHEN NO_DATA_FOUND  THEN
            OUT_RESULT := 'WRONG';
        END;
      WHEN '2' THEN
        BEGIN
          SELECT MR_NAME INTO OUT_NAME FROM METER_READER WHERE MR_ID = IN_USER_ID AND PSWORD = IN_USER_PASSWORD;
          OUT_RESULT := 'RIGHT';
          EXCEPTION WHEN NO_DATA_FOUND  THEN
          OUT_RESULT := 'WRONG';
        END;
      WHEN '3' THEN
        BEGIN
          IF IN_USER_ID = 4999 AND IN_USER_PASSWORD = '4999' THEN
            OUT_NAME := '管理员';
            OUT_RESULT := 'RIGHT';
          ELSE
            OUT_RESULT := 'WRONG';
          END IF;
        END;
    END CASE;
  END;
/

--查询用户所有银行卡号
create PROCEDURE QUERY_CARD_NUM_BY_CUSTOMER_ID(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,
                                                             OUT_RES OUT VARCHAR2)AS
  bank_card_rec         BANK_CARD%ROWTYPE;
  CURSOR card_num_cursor IS
    SELECT * FROM BANK_CARD
        WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
  BEGIN
    OPEN card_num_cursor;
    LOOP
      FETCH card_num_cursor INTO bank_card_rec;
      EXIT WHEN card_num_cursor%NOTFOUND;
      OUT_RES := OUT_RES || bank_card_rec.BANK_ID || ',' || bank_card_rec.CARD_ID || ';';
    END LOOP;
    CLOSE card_num_cursor;
  END;
/

--查询用户所有设备号
create PROCEDURE QUERY_DEVICE_ID_BY_CUSTOMER_ID(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,
                                                             OUT_RES OUT VARCHAR2)AS
  device_id_rec         DEVICE%ROWTYPE;
  CURSOR device_id_cursor IS
    SELECT * FROM DEVICE
        WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
  BEGIN
    OPEN device_id_cursor;
    LOOP
      FETCH device_id_cursor INTO device_id_rec;
      EXIT WHEN device_id_cursor%NOTFOUND;
      OUT_RES := OUT_RES || device_id_rec.DEVICE_ID || ',' || device_id_rec.DEVICE_NAME || ';';
    END LOOP;
    CLOSE device_id_cursor;
  END;
/

--更新滞纳金与实缴金额
CREATE OR REPLACE PROCEDURE UPDATE_LATE_FEE_BY_CUSTOMER_ID(in_customer_id IN  CUSTOMER.CUSTOMER_ID%TYPE) AS
  TYPE Ref_cursor_type IS REF CURSOR;
  residentCurRatio_   CODE_TABLE.C_VALUE%TYPE; -- 居民当年违约金比例
  residentCrossRatio_ CODE_TABLE.C_VALUE%TYPE; -- 居民跨年违约金比例
  cropCurRatio_       CODE_TABLE.C_VALUE%TYPE; -- 企业当年违约金比例
  cropCrossRatio_     CODE_TABLE.C_VALUE%TYPE;-- 企业跨年违约金比例
  pr_id_query_sql    VARCHAR2(200);
  pr_id_cursor       Ref_cursor_type;
  pr_id_temp         POWER_RATE_LIST.PR_ID%TYPE;
  payable_date_      POWER_RATE_LIST.PAYABLE_DATE%TYPE;
  date_delta         NUMBER;
  late_fee_          POWER_RATE_LIST.LATE_FEE%TYPE := 0;
  actual_fee_        POWER_RATE_LIST.ACTUAL_FEE%TYPE;
  paid_fee_          POWER_RATE_LIST.PAID_FEE%TYPE;
  -- 设备游标
  CURSOR device_cursor IS
    SELECT DEVICE_ID, DEVICE_TYPE
    FROM DEVICE
    WHERE DEVICE.CUSTOMER_ID = in_customer_id;

  -- 设备记录
  TYPE Device_rec IS RECORD (
  device_id DEVICE.DEVICE_ID%TYPE,
  device_type DEVICE.DEVICE_TYPE%TYPE
  );

  -- 设备记录的集合
  TYPE Device_rec_array IS VARRAY (10) OF Device_rec;

  device_rec_        Device_rec;
  device_rec_array_  Device_rec_array;
  i                  NUMBER := 1;
  k                  NUMBER := 1;
  BEGIN
    device_rec_array_ := Device_rec_array(); -- 初始化
    OPEN device_cursor;
    LOOP
      FETCH device_cursor INTO device_rec_;
      EXIT WHEN device_cursor%NOTFOUND;
      device_rec_array_.extend(1);
      device_rec_array_(i) := device_rec_;
      i := i + 1;
    END LOOP;
    CLOSE device_cursor;
    SELECT C_VALUE INTO residentCurRatio_ FROM CODE_TABLE WHERE C_KEY = '居民当年违约金比例';
    SELECT C_VALUE INTO residentCrossRatio_ FROM CODE_TABLE WHERE C_KEY = '居民跨年违约金比例';
    SELECT C_VALUE INTO cropCurRatio_ FROM CODE_TABLE WHERE C_KEY = '企业当年违约金比例';
    SELECT C_VALUE INTO cropCrossRatio_ FROM CODE_TABLE WHERE C_KEY = '企业跨年违约金比例';
    IF device_rec_array_.COUNT = 0 THEN
      NULL;
    ELSE
    FOR j IN device_rec_array_.FIRST..device_rec_array_.LAST LOOP
      pr_id_query_sql := ('SELECT PR_ID FROM POWER_RATE_LIST WHERE DEVICE_ID = ' || device_rec_array_(j).device_id || 'AND PAY_STATE != 1');
      OPEN pr_id_cursor for pr_id_query_sql;
      LOOP
        FETCH pr_id_cursor INTO pr_id_temp;
        EXIT WHEN pr_id_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(pr_id_temp);
        SELECT PAYABLE_DATE,PAID_FEE INTO payable_date_,paid_fee_
        FROM POWER_RATE_LIST
        WHERE PR_ID = pr_id_temp;
        DBMS_OUTPUT.PUT_LINE('----------------------------');
        DBMS_OUTPUT.PUT_LINE('PR_ID：' || pr_id_temp);
        late_fee_ := 0;
        date_delta := TO_DATE(SYSDATE) - TO_DATE(payable_date_);
        DBMS_OUTPUT.PUT_LINE('late_fee_：' || late_fee_);
        IF (date_delta > 0) -- 应缴日期已过
        THEN
          late_fee_ := (CASE device_rec_array_(j).device_type
                       WHEN 01
                         THEN TO_NUMBER(residentCurRatio_) * date_delta * paid_fee_
                       WHEN 02
                         THEN TO_NUMBER(cropCurRatio_) * date_delta * paid_fee_
                       ELSE 0 END);
        END IF;
        DBMS_OUTPUT.PUT_LINE('date_delta1：' || date_delta);
        DBMS_OUTPUT.PUT_LINE('late_fee_1：' || late_fee_);
        date_delta := (TO_DATE(SYSDATE) - (ADD_MONTHS(TRUNC(TO_DATE(payable_date_), 'yyyy'), 12) - 1));
        IF (date_delta > 0) -- 欠费跨年
        THEN late_fee_ := late_fee_ + (CASE device_rec_array_(j).device_type
                                     WHEN 01
                                       THEN (TO_NUMBER(residentCrossRatio_) - TO_NUMBER(residentCurRatio_)) * date_delta * paid_fee_
                                     WHEN 02
                                       THEN (TO_NUMBER(cropCrossRatio_) - TO_NUMBER(cropCurRatio_)) * date_delta * paid_fee_
                                     ELSE 0 END);
        END IF;
        DBMS_OUTPUT.PUT_LINE('date_delta2：' || date_delta);
        DBMS_OUTPUT.PUT_LINE('late_fee_2：' || late_fee_);
        UPDATE POWER_RATE_LIST
        SET LATE_FEE = late_fee_
        WHERE PR_ID = pr_id_temp;
        UPDATE POWER_RATE_LIST
        SET ACTUAL_FEE = PAID_FEE + LATE_FEE
        WHERE PR_ID = pr_id_temp;
      END LOOP;
    END LOOP;
    CLOSE pr_id_cursor;
    END IF;
    COMMIT ;-- 提交更新
  END UPDATE_LATE_FEE_BY_CUSTOMER_ID;
/

--关键业务流程
--抄表 生成电费清单 自动扣费
create PROCEDURE UPDATE_METER_LOG_BY_DEVICE_ID(IN_DEVICE_ID IN DEVICE.DEVICE_ID%TYPE,
                                                             IN_MT_DATE IN METER_LOG.MT_DATE%TYPE,
                                                             IN_MT_NUMBER IN METER_LOG.MT_NUMBER%TYPE,
                                                             IN_MR_ID IN METER_LOG.MR_ID%TYPE,
                                                             OUT_RES OUT VARCHAR2) IS
  CURSOR DEVICE_PR IS
    SELECT PR_ID FROM POWER_RATE_LIST WHERE DEVICE_ID = IN_DEVICE_ID AND PAY_STATE != '1' ORDER BY MT_DATE ASC;
  --变量
  MT_NUMBER_EXCEPTION   EXCEPTION ;
  device_type_          DEVICE.DEVICE_TYPE%TYPE;
  device_name_          DEVICE.DEVICE_NAME%TYPE;
  pricePerKwh_          CODE_TABLE.C_VALUE%TYPE;
  begin_number_         POWER_RATE_LIST.BEGIN_NUMBER%TYPE;
  end_number_           POWER_RATE_LIST.END_NUMBER%TYPE;
  basic_cost_           POWER_RATE_LIST.BASIC_COST%TYPE := 0.00;
  additional_cost1_     POWER_RATE_LIST.ADDITIONAL_COST_1%TYPE := 0.00;
  additional_cost2_     POWER_RATE_LIST.ADDITIONAL_COST_2%TYPE := 0.00;
  paid_fee_             POWER_RATE_LIST.PAID_FEE%TYPE := 0.00;
  actual_fee_           POWER_RATE_LIST.ACTUAL_FEE%TYPE := 0.00;
  late_fee_             POWER_RATE_LIST.LATE_FEE%TYPE := 0.00;
  pay_date_             POWER_RATE_LIST.PAY_DATE%TYPE := NULL;
  already_fee_          POWER_RATE_LIST.ALREADY_FEE%TYPE := 0.00;
  pay_state_            POWER_RATE_LIST.PAY_STATE%TYPE := 0;
  pr_id_                POWER_RATE_LIST.PR_ID%TYPE;
  balance_before        CUSTOMER.BALANCE%TYPE;
  balance_now           CUSTOMER.BALANCE%TYPE;
  customer_id_          CUSTOMER.CUSTOMER_ID%TYPE;
  fee_wait_             POWER_RATE_LIST.ALREADY_FEE%TYPE;

  BEGIN
    SELECT DEVICE_TYPE,DEVICE_NAME,CUSTOMER_ID INTO device_type_,device_name_,customer_id_ FROM DEVICE WHERE DEVICE_ID = IN_DEVICE_ID;
    SELECT C_VALUE INTO pricePerKwh_ FROM CODE_TABLE WHERE C_KEY = '每度电价格';
    BEGIN
      --找到上次的电表度数记录
      SELECT MT_NUMBER INTO begin_number_ FROM METER_LOG WHERE DEVICE_ID = IN_DEVICE_ID AND ROWNUM = 1 ORDER BY MT_DATE DESC;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      --首次抄表
      begin_number_ := 0;
    END;
    --验证
    end_number_ := IN_MT_NUMBER;
    IF begin_number_ > end_number_
      THEN
        RAISE MT_NUMBER_EXCEPTION;
    END IF;
    --插入新的抄表记录
    INSERT INTO METER_LOG (MT_DATE,DEVICE_ID,CUSTOMER_ID,MT_NUMBER,MR_ID) VALUES (IN_MT_DATE,IN_DEVICE_ID,customer_id_,IN_MT_NUMBER,IN_MR_ID);
    IF begin_number_ = end_number_ THEN
      --读数不变的情况
      INSERT INTO POWER_RATE_LIST (DEVICE_ID,CUSTOMER_ID,MT_DATE,BEGIN_NUMBER,END_NUMBER,BASIC_COST,
                                   ADDITIONAL_COST_1,ADDITIONAL_COST_2,PAID_FEE,ACTUAL_FEE,LATE_FEE,PAYABLE_DATE,PAY_DATE,ALREADY_FEE,PAY_STATE)
      VALUES (IN_DEVICE_ID,customer_id_,IN_MT_DATE,begin_number_,end_number_,
              basic_cost_,additional_cost1_,additional_cost2_,paid_fee_,
              actual_fee_,late_fee_,ADD_MONTHS(IN_MT_DATE,1),pay_date_,already_fee_,'1');
      COMMIT ;
      UPDATE_LATE_FEE_BY_CUSTOMER_ID(customer_id_);
      DBMS_OUTPUT.PUT_LINE('[SUCCESS] 您已成功更新抄表记录，该电表读数不变');
      OUT_RES := '[SUCCESS] 您已成功更新抄表记录，该电表读数不变';
    ELSE
      --计算相关金额
      basic_cost_ := TO_NUMBER(pricePerKwh_) * (end_number_ - begin_number_);
      additional_cost1_ := basic_cost_ * 0.08;
      CASE device_type_
        WHEN '01'
          THEN
            additional_cost2_ := basic_cost_ * 0.10;
        WHEN '02'
          THEN
            additional_cost2_ := basic_cost_ * 0.15;
      END CASE;
      paid_fee_ := basic_cost_+ additional_cost1_ + additional_cost2_;
      actual_fee_ := paid_fee_;
      --检查余额
      SELECT BALANCE INTO balance_before FROM CUSTOMER WHERE CUSTOMER_ID = customer_id_;

      --插入电费清单
      INSERT INTO POWER_RATE_LIST (DEVICE_ID,CUSTOMER_ID,MT_DATE,BEGIN_NUMBER,END_NUMBER,BASIC_COST,
                                   ADDITIONAL_COST_1,ADDITIONAL_COST_2,PAID_FEE,ACTUAL_FEE,LATE_FEE,PAYABLE_DATE,PAY_DATE,ALREADY_FEE,PAY_STATE)
      VALUES (IN_DEVICE_ID,customer_id_,IN_MT_DATE,begin_number_,end_number_,
              basic_cost_,additional_cost1_,additional_cost2_,paid_fee_,
              actual_fee_,late_fee_,ADD_MONTHS(IN_MT_DATE,1),pay_date_,already_fee_,pay_state_);
      COMMIT ;
      UPDATE_LATE_FEE_BY_CUSTOMER_ID(customer_id_);
      --更新余额表与用户表
      IF balance_before > 0 THEN
        balance_now := balance_before;
        OPEN DEVICE_PR;
        LOOP
          FETCH DEVICE_PR INTO pr_id_;
          EXIT WHEN DEVICE_PR%NOTFOUND;
          EXIT WHEN balance_now = 0;
          SELECT (ACTUAL_FEE - ALREADY_FEE) INTO fee_wait_ FROM POWER_RATE_LIST WHERE PR_ID = pr_id_;
          IF fee_wait_ > balance_now THEN
            UPDATE POWER_RATE_LIST
            SET PAY_STATE   = '2',
                PAY_DATE    = IN_MT_DATE,
                ALREADY_FEE = ALREADY_FEE + balance_now
            WHERE PR_ID = pr_id_;
            INSERT INTO BALANCE (CUSTOMER_ID,BALANCE_TYPE,BALANCE_DELTA,PR_ID,TIME_CUR) VALUES (customer_id_,'2',balance_now,pr_id_,SYSDATE);
            UPDATE CUSTOMER SET BALANCE = 0 WHERE CUSTOMER_ID = customer_id_;
            balance_now := 0;
          ELSE
            UPDATE POWER_RATE_LIST
            SET PAY_STATE   = '1',
                PAY_DATE    = IN_MT_DATE,
                ALREADY_FEE = ALREADY_FEE + fee_wait_
            WHERE PR_ID = pr_id_;
            INSERT INTO BALANCE (CUSTOMER_ID,BALANCE_TYPE,BALANCE_DELTA,PR_ID,TIME_CUR) VALUES (customer_id_,'2',fee_wait_,pr_id_,SYSDATE);
            UPDATE CUSTOMER SET BALANCE = BALANCE - fee_wait_ WHERE CUSTOMER_ID = customer_id_;
            balance_now := balance_now - fee_wait_;
          END IF;
        END LOOP;
        CLOSE DEVICE_PR;
        DBMS_OUTPUT.PUT_LINE('[SUCCESS] 您已成功更新设备ID为'|| IN_DEVICE_ID || '的抄表记录，并从余额中自动扣除了'|| (balance_before - balance_now) ||'元');
        OUT_RES := '[SUCCESS] 您已成功更新设备ID为'|| IN_DEVICE_ID || '的抄表记录，并从余额中自动扣除了'|| (balance_before - balance_now) ||'元';
      ELSE
        DBMS_OUTPUT.PUT_LINE('[SUCCESS] 您已成功更新设备ID为'|| IN_DEVICE_ID || '的抄表记录');
        OUT_RES := '[SUCCESS] 您已成功更新设备ID为'|| IN_DEVICE_ID || '的抄表记录';
      END IF;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR] 您输入的设备号不存在');
      OUT_RES := '[ERROR] 您输入的设备号不存在';
    WHEN MT_NUMBER_EXCEPTION THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR] 您输入的电表读数小于上月读数，输入失败');
      OUT_RES := '[ERROR] 您输入的电表读数小于上月读数，输入失败';
  END UPDATE_METER_LOG_BY_DEVICE_ID;
/

--查询欠费清单
create PROCEDURE query_PAID_Fee_By_Customer_ID(in_customer_id IN  CUSTOMER.CUSTOMER_ID%TYPE,
                                                          OUT_RESULT1 OUT VARCHAR2,
                                                          OUT_RESULT2 OUT VARCHAR2,
                                                          OUT_RESULT3 OUT VARCHAR2) AS
-- 设备游标
  CURSOR device_cursor IS
    SELECT DEVICE_ID, DEVICE_TYPE
    FROM DEVICE
    WHERE DEVICE.CUSTOMER_ID = in_customer_id;

  -- 设备记录
  TYPE Device_rec IS RECORD (
  device_id DEVICE.DEVICE_ID%TYPE,
  device_type DEVICE.DEVICE_TYPE%TYPE
  );
  TYPE List_rec IS RECORD (
  device_id DEVICE.DEVICE_ID%TYPE,
  total_fee POWER_RATE_LIST.PAID_FEE%TYPE
  );
  --同一设备每月的清单
  TYPE Ref_cursor_type IS REF CURSOR;
  -- 设备记录的集合
  TYPE Device_rec_array IS VARRAY (10) OF Device_rec;
  TYPE List_rec_array IS VARRAY (10) OF List_rec;

  device_rec_            Device_rec;
  device_rec_array_      Device_rec_array;
  list_rec_array_        List_rec_array;
  ref_cursor_list        Ref_cursor_type;
  i                      NUMBER := 1;
  already_fee_           POWER_RATE_LIST.ALREADY_FEE%TYPE;
  paid_fee_              POWER_RATE_LIST.PAID_FEE%TYPE := 0;
  late_fee_              POWER_RATE_LIST.LATE_FEE%TYPE := 0;
  leave_fee              POWER_RATE_LIST.LATE_FEE%TYPE := 0;
  actual_fee_            POWER_RATE_LIST.ACTUAL_FEE%TYPE;
  payable_date_          POWER_RATE_LIST.PAYABLE_DATE%TYPE;
  pr_id_                 POWER_RATE_LIST.PR_ID%TYPE;
  flag                   VARCHAR2(1) := '0';
  PAID_FEE_TOTAL         POWER_RATE_LIST.PAID_FEE%TYPE;
  in_customer_id_error   EXCEPTION ;

  BEGIN
    device_rec_array_ := Device_rec_array(); -- 初始化
    list_rec_array_ := List_rec_array();
    PAID_FEE_TOTAL := 0;
    OPEN device_cursor;
    LOOP
      FETCH device_cursor INTO device_rec_;
      EXIT WHEN device_cursor%NOTFOUND;
      device_rec_array_.extend(1);
      device_rec_array_(i) := device_rec_;
      list_rec_array_.extend(1);
      list_rec_array_(i).device_id := device_rec_.device_id;
      list_rec_array_(i).total_fee := 0;
      i := i + 1;
    END LOOP;
    CLOSE device_cursor;
    UPDATE_LATE_FEE_BY_CUSTOMER_ID(in_customer_id);
    IF device_rec_array_.COUNT = 0 THEN
      RAISE in_customer_id_error;
    END IF;
    FOR j IN device_rec_array_.FIRST..device_rec_array_.LAST LOOP
      OPEN ref_cursor_list FOR SELECT PR_ID FROM POWER_RATE_LIST
                               WHERE POWER_RATE_LIST.DEVICE_ID = device_rec_array_(j).device_id AND PAY_STATE != 1 ORDER BY MT_DATE ASC;
      LOOP
        FETCH ref_cursor_list INTO pr_id_;
        EXIT WHEN ref_cursor_list%NOTFOUND;
        flag := '1';
        SELECT PAID_FEE,ALREADY_FEE,LATE_FEE,ACTUAL_FEE,PAYABLE_DATE
            INTO paid_fee_, already_fee_, late_fee_, actual_fee_,payable_date_
        FROM POWER_RATE_LIST
        WHERE PR_ID = pr_id_;
        -- 统计总欠费
        PAID_FEE_TOTAL := PAID_FEE_TOTAL + actual_fee_ - already_fee_;
        -- 统计该设备总欠费
        list_rec_array_(j).total_fee := list_rec_array_(j).total_fee + actual_fee_ - already_fee_;
        IF paid_fee_ <= already_fee_ THEN
          leave_fee := 0;
        ELSE
          leave_fee := paid_fee_ - already_fee_;
        END IF;
        -- 输出该设备某月欠费情况
        DBMS_OUTPUT.PUT_LINE('设备号：' || device_rec_array_(j).device_id || '  设备类型：'|| device_rec_array_(j).device_type ||
                             '  客户编号:' || in_customer_id || '  应缴日期:' || TO_CHAR(payable_date_,'yyyy/mm/dd'));
        DBMS_OUTPUT.PUT_LINE('单月待缴金额:' || (actual_fee_ - already_fee_) || '  已缴费金额:' || already_fee_ || '  剩余缴费:' || leave_fee ||  '  滞纳金:' || late_fee_);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');

        OUT_RESULT1 := OUT_RESULT1 || device_rec_array_(j).device_id || ',' || device_rec_array_(j).device_type || ',' || in_customer_id|| ','
                       || TO_CHAR(payable_date_,'yyyy/mm/dd') || ',' || (actual_fee_ - already_fee_) || ','|| already_fee_ || ','|| leave_fee || ',' || late_fee_ || ';';
      END LOOP;
      -- 如果该设备没有欠费清单
      IF flag = '0' THEN
        DBMS_OUTPUT.PUT_LINE('设备号：' || device_rec_array_(j).device_id || '  设备类型：'|| device_rec_array_(j).device_type ||
                             '  客户编号:' || in_customer_id);
        OUT_RESULT1 := OUT_RESULT1 || device_rec_array_(j).device_id || ',' || device_rec_array_(j).device_type || ',' || in_customer_id|| ','
                       || '#' || ',' || 0 || ','|| 0 || ','|| 0 || ',' || 0 || ';';
        DBMS_OUTPUT.PUT_LINE('该设备无待缴费清单');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
      END IF;
      CLOSE ref_cursor_list;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('客户编号:' || in_customer_id || '  总待缴金额:' || PAID_FEE_TOTAL);
    OUT_RESULT2 := (in_customer_id || ',' || PAID_FEE_TOTAL);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    FOR k IN list_rec_array_.FIRST..list_rec_array_.LAST LOOP
      DBMS_OUTPUT.PUT_LINE('客户编号:' || in_customer_id || '  设备编号'|| list_rec_array_(k).device_id || '  总待缴金额:' || list_rec_array_(k).total_fee);
      OUT_RESULT3 := OUT_RESULT3 || (in_customer_id || ','|| list_rec_array_(k).device_id || ',' || list_rec_array_(k).total_fee || ';');
    END LOOP;
    EXCEPTION WHEN in_customer_id_error THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR]输入用户ID有误');
  END query_PAID_Fee_By_Customer_ID;
/

--缴费
create PROCEDURE UPDATE_PAYFEE_BY_DEVICE_ID (IN_DEVICE_ID IN DEVICE.DEVICE_ID%TYPE,
                                             IN_FEE IN POWER_RATE_LIST.PAID_FEE%TYPE,
                                             IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,
                                             IN_CARD_ID IN BANK_CARD.CARD_ID%TYPE,
                                             OUT_RES OUT VARCHAR2) AS
--变量表
  pr_id_temp          POWER_RATE_LIST.PR_ID%TYPE;
  fee_wait            POWER_RATE_LIST.PAID_FEE%TYPE;
  balance_before      CUSTOMER.BALANCE%TYPE; -- 用户缴费前余额
  balance_before_      CUSTOMER.BALANCE%TYPE; -- 用户缴费前余额
  balance_now         CUSTOMER.BALANCE%TYPE;
  bank_id_            BANK.BANK_ID%TYPE;
  bt_id_              BANK_TRANSFER_RECORD.BT_ID%TYPE;
  pay_id_             PAY_LOG.PAY_ID%TYPE;
  notes_              PAY_LOG.NOTES%TYPE := '';
  pay_state_          POWER_RATE_LIST.PAY_STATE%TYPE;
  counts              NUMBER := 0;
  device_name_        DEVICE.DEVICE_NAME%TYPE;
  fee_error           EXCEPTION ;
  customer_id_error   EXCEPTION ;
  card_id_error       EXCEPTION ;

  --游标选出所有待缴费记录 并升序排列
  CURSOR list_cursor IS
    SELECT PR_ID FROM POWER_RATE_LIST
    WHERE DEVICE_ID = IN_DEVICE_ID AND PAY_STATE != 1
    ORDER BY MT_DATE ASC;

  BEGIN
    SELECT DEVICE_NAME INTO device_name_ FROM DEVICE  WHERE DEVICE_ID = IN_DEVICE_ID;
    --初始化余额和银行ID
    BEGIN
      SELECT BALANCE INTO balance_before FROM CUSTOMER WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
      balance_before_ := balance_before;
      balance_now := balance_before + IN_FEE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE customer_id_error;
    END;
    BEGIN
      SELECT BANK_ID INTO bank_id_ FROM BANK_CARD WHERE CARD_ID = IN_CARD_ID AND CUSTOMER_ID = IN_CUSTOMER_ID;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE card_id_error;
    END;
    IF IN_FEE <=0 THEN
      RAISE fee_error;
    END IF;
    --更新该用户滞纳金
    UPDATE_LATE_FEE_BY_CUSTOMER_ID(IN_CUSTOMER_ID);
    --获得该设备的所有待缴费账单号
    OPEN list_cursor;
    LOOP
      --总余额不足 则退出循环
      EXIT WHEN balance_now <= 0.00;

      FETCH list_cursor INTO pr_id_temp;
      EXIT WHEN list_cursor%NOTFOUND;
      SELECT (ACTUAL_FEE - ALREADY_FEE) INTO fee_wait
      FROM POWER_RATE_LIST
      WHERE PR_ID = pr_id_temp;

      --修改余额表
      IF balance_before >= fee_wait THEN
        balance_before := balance_before - fee_wait;
        INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PR_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'2',fee_wait,pr_id_temp,SYSDATE);
      --如果余额不足支付 扣光余额
      ELSIF balance_before < fee_wait AND balance_before > 0 THEN
        INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PR_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'2',balance_before,pr_id_temp,SYSDATE);
        balance_before := 0;
      ELSE
        NULL;
      END IF;
      --更新本次支付状态
      IF fee_wait <= balance_now THEN
        pay_state_ := '1';
        balance_now := balance_now - fee_wait;
      ELSE
        pay_state_ := '2';
        fee_wait := balance_now;
        balance_now := 0.00;
      END IF;
      --保存账单号以及金额
      notes_ := notes_ || pr_id_temp || ',' || fee_wait || ';';
      --修改电费清单
      UPDATE POWER_RATE_LIST
      SET PAY_STATE   = pay_state_,
          PAY_DATE    = SYSDATE,
          ALREADY_FEE = ALREADY_FEE + fee_wait
      WHERE PR_ID = pr_id_temp;
      counts := counts + 1;
    END LOOP;
    CLOSE list_cursor;

    --更新账户余额
    UPDATE CUSTOMER SET BALANCE = balance_now WHERE CUSTOMER_ID = IN_CUSTOMER_ID;
    --修改银行记录表
    INSERT INTO BANK_TRANSFER_RECORD (BANK_ID,CUSTOMER_ID,TRANSFER_AMOUNT,TRANSFER_TIME,CARD_ID)
    VALUES (bank_id_,IN_CUSTOMER_ID,IN_FEE,SYSDATE,IN_CARD_ID);
    SELECT BT_ID_SEQUENCE.currval INTO bt_id_ FROM dual;

    --修改缴费日志
    INSERT INTO PAY_LOG (CUSTOMER_ID,PAY_TIME,PAY_AMOUNT,PAY_TYPE,BANK_ID,BT_ID,NOTES)
    VALUES(IN_CUSTOMER_ID,SYSDATE,IN_FEE,'01',bank_id_,bt_id_,notes_);
    SELECT PAY_ID_SEQUENCE.currval INTO pay_id_ FROM dual;

    --若缴费还有剩余 转入余额并记录
    IF counts = 0 THEN
      INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PAY_ID, BT_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'1',IN_FEE,pay_id_,bt_id_,SYSDATE);
      DBMS_OUTPUT.PUT_LINE('[SUCCESS]该设备无待缴费账单，直接转入账户余额 ' || IN_FEE || '元');
      OUT_RES := '[SUCCESS]该设备无待缴费账单，直接转入账户余额 ' || IN_FEE || '元';
    ELSE
      IF balance_before_ = 0 THEN   --
        IF balance_now > 0 THEN     --
          INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PAY_ID, BT_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'1',balance_now,pay_id_,bt_id_,SYSDATE);
          DBMS_OUTPUT.PUT_LINE('[SUCCESS]缴费成功，共缴费'|| (IN_FEE - balance_now) || '元，并转入账户余额 ' || balance_now || '元');
          OUT_RES := '[SUCCESS]缴费成功，共缴费'|| (IN_FEE - balance_now) || '元，并转入账户余额 ' || balance_now || '元';
        ELSE                        --
          DBMS_OUTPUT.PUT_LINE('[SUCCESS]缴费成功，共缴费'|| IN_FEE || '元');
          OUT_RES := '[SUCCESS]缴费成功，共缴费'|| IN_FEE || '元';
        END IF;
      ELSE                          --
        IF balance_before_ < balance_now THEN
          IF balance_now >= IN_FEE THEN
            INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PAY_ID, BT_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'1',IN_FEE,pay_id_,bt_id_,SYSDATE);
            DBMS_OUTPUT.PUT_LINE('[SUCCESS]缴费成功，共缴费'|| (IN_FEE + balance_before_ - balance_now) || '元，并转入账户余额' || IN_FEE || '元');
            OUT_RES := '[SUCCESS]缴费成功，共缴费'|| (IN_FEE + balance_before_ - balance_now) || '元，并转入账户余额' || IN_FEE || '元';
          ELSE
            INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PAY_ID, BT_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'1',balance_now,pay_id_,bt_id_,SYSDATE);
            DBMS_OUTPUT.PUT_LINE('[SUCCESS]缴费成功，共缴费'|| (IN_FEE + balance_before_ - balance_now) || '元，并转入账户余额 ' || balance_now || '元');
            OUT_RES := '[SUCCESS]缴费成功，共缴费'|| (IN_FEE + balance_before_ - balance_now) || '元，并转入账户余额 ' || balance_now || '元';
          END IF;
        ELSIF balance_before >= balance_now THEN
          DBMS_OUTPUT.PUT_LINE('[SUCCESS]缴费成功，共缴费'|| (IN_FEE + balance_before_ - balance_now) || '元');
          OUT_RES := '[SUCCESS]缴费成功，共缴费'|| (IN_FEE + balance_before_ - balance_now) || '元';
        END IF;
      END IF;
    END IF;
    --提交事务
    COMMIT;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR]您输入的设备号不存在');
      OUT_RES := 'NO';
      WHEN card_id_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]你输入的卡号不存在或不属于您');
      WHEN fee_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]您的缴费金额应当大于0');
      WHEN customer_id_error THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR]您输入的用户ID有误');
    END UPDATE_PAYFEE_BY_DEVICE_ID;
/

--客户冲正
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
            INSERT INTO BALANCE (CUSTOMER_ID, BALANCE_TYPE, BALANCE_DELTA, PAY_ID, BT_ID,TIME_CUR) VALUES (IN_CUSTOMER_ID,'3',fee_sum,pay_id_,IN_BT_ID,SYSDATE);
            DBMS_OUTPUT.PUT_LINE('[SUCCESS]已成功将编号为' || pay_id_ || '缴费记录更新为已冲正');
            OUT_RES := OUT_RES || '[SUCCESS]已成功将编号为' || pay_id_ || '缴费记录更新为已冲正';
            DBMS_OUTPUT.PUT_LINE('[SUCCESS]已成功将冲正所得的' || fee_sum || '元转入余额');
            OUT_RES := OUT_RES || '，并将冲正所得的' || fee_sum || '元转入余额';
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

--对总账
create PROCEDURE CHECK_BY_DATE(IN_BANK_ID IN BANK.BANK_ID%TYPE,
                                             IN_CHECK_DATE IN DATE,
                                             OUT_RES OUT VARCHAR2) AS

  bank_count_                     ACCOUNT_TOTAL.BANK_COUNT%TYPE := 0;
  bank_amount_                    ACCOUNT_TOTAL.BANK_AMOUNT%TYPE := 0.00;
  enterprise_count_               ACCOUNT_TOTAL.ENTERPRISE_COUNT%TYPE := 0;
  enterprise_amount_              ACCOUNT_TOTAL.ENTERPRISE_AMOUNT%TYPE := 0.00;
  is_success_                     ACCOUNT_TOTAL.IS_SUCCESS%TYPE;
  bt_rec_                         BANK_TRANSFER_RECORD%ROWTYPE;
  pay_log_rec_                    PAY_LOG%ROWTYPE;
  pay_log_correct_rec_            PAY_LOG%ROWTYPE;
  bt_id_                          BANK_TRANSFER_RECORD.BT_ID%TYPE;
  pay_id_                         PAY_LOG.PAY_ID%TYPE;
  transfer_amount_                BANK_TRANSFER_RECORD.TRANSFER_AMOUNT%TYPE;
  pay_amount_                     PAY_LOG.PAY_AMOUNT%TYPE;
  absence_bank_amount             ACCOUNT_TOTAL.BANK_AMOUNT%TYPE := 0.00;
  absence_bank_count              ACCOUNT_TOTAL.BANK_COUNT%TYPE := 0;
  absence_enterprise_count        ACCOUNT_TOTAL.ENTERPRISE_COUNT%TYPE := 0;
  absence_enterprise_amount       ACCOUNT_TOTAL.ENTERPRISE_AMOUNT%TYPE := 0.00;
  correct_count_                  NUMBER := 0;
  input_error                     EXCEPTION ;
  bank_name_                      BANK.BANK_NAME%TYPE;

  CURSOR bt_rec_cursor IS
    SELECT * FROM BANK_TRANSFER_RECORD
      WHERE BANK_ID = IN_BANK_ID AND TO_DATE(TRANSFER_TIME) = IN_CHECK_DATE
      ORDER BY BT_ID;

  CURSOR pay_log_rec_cursor IS
    SELECT * FROM PAY_LOG
      WHERE BANK_ID = IN_BANK_ID AND TO_DATE(PAY_TIME) = IN_CHECK_DATE AND PAY_TYPE != '02'
      ORDER BY PAY_ID;

  CURSOR pay_log_correct_rec_cursor IS
    SELECT * FROM PAY_LOG
      WHERE BANK_ID = IN_BANK_ID AND TO_DATE(PAY_TIME) = IN_CHECK_DATE AND PAY_TYPE = '02'
      ORDER BY PAY_ID;

  BEGIN
    --对总账
    BEGIN
      SELECT BANK_NAME INTO bank_name_ FROM BANK WHERE BANK_ID = IN_BANK_ID;
      EXCEPTION  WHEN NO_DATA_FOUND THEN
        RAISE input_error;
    END;
    SELECT SUM(TRANSFER_AMOUNT),COUNT(BT_ID) INTO bank_amount_,bank_count_ FROM BANK_TRANSFER_RECORD
        WHERE BANK_ID = IN_BANK_ID AND TO_DATE(TRANSFER_TIME) = IN_CHECK_DATE;
    SELECT SUM(PAY_AMOUNT),COUNT(PAY_ID) INTO enterprise_amount_,enterprise_count_ FROM PAY_LOG
      WHERE BANK_ID = IN_BANK_ID AND TO_DATE(PAY_TIME) = IN_CHECK_DATE AND PAY_TYPE != '02';
    IF bank_amount_ IS NULL THEN
      bank_amount_ := 0;
    END IF;
    IF enterprise_amount_ IS NULL THEN
      enterprise_amount_ := 0;
    END IF;
    DBMS_OUTPUT.PUT_LINE('银行总金额: ' || bank_amount_ || '   银行总笔数: '  || bank_count_);
    OUT_RES := bank_amount_ || ';'  || bank_count_ || ';';
    DBMS_OUTPUT.PUT_LINE('公司总金额: ' || enterprise_amount_ || '   公司总笔数: ' || enterprise_count_);
    OUT_RES := OUT_RES || enterprise_amount_ || ';' || enterprise_count_ || ';';
    IF bank_amount_ = enterprise_amount_ AND bank_count_ = enterprise_count_ THEN
      is_success_ := '00';
      OUT_RES := OUT_RES || '00' || ';';
      DBMS_OUTPUT.PUT_LINE('[SUCCESS]对总账结束，'|| TO_CHAR(IN_CHECK_DATE,'yyyy-mm-dd') || '日两账单无异常');
      OUT_RES := OUT_RES || '[SUCCESS]对总账结束，'|| TO_CHAR(IN_CHECK_DATE,'yyyy-mm-dd') || '日两账单无异常';
    ELSE
      is_success_ := '01';
      OUT_RES := OUT_RES || '01' || ';';
      DBMS_OUTPUT.PUT_LINE('[ERROR]对总账结束，'|| TO_CHAR(IN_CHECK_DATE,'yyyy-mm-dd') || '日两账单出现异常，执行对明细账操作');
      OUT_RES := OUT_RES || '[ERROR]对总账结束，'|| TO_CHAR(IN_CHECK_DATE,'yyyy-mm-dd') || '日两账单出现异常，执行对明细账操作'|| ';';
    END IF;
    INSERT INTO ACCOUNT_TOTAL (ACCOUNT_DATE, BANK_ID, BANK_COUNT, BANK_AMOUNT, ENTERPRISE_COUNT, ENTERPRISE_AMOUNT, IS_SUCCESS)
      VALUES  (IN_CHECK_DATE,IN_BANK_ID,bank_count_,bank_amount_,enterprise_count_,enterprise_amount_,is_success_);
    --对明细账
    IF is_success_ = '01' THEN
      --情况一 已转账 未缴费 即银行缺失
      OPEN pay_log_rec_cursor;
      LOOP
        FETCH pay_log_rec_cursor INTO pay_log_rec_;
        EXIT WHEN pay_log_rec_cursor%NOTFOUND;
        BEGIN
          SELECT TRANSFER_AMOUNT INTO transfer_amount_ FROM BANK_TRANSFER_RECORD WHERE BT_ID = pay_log_rec_.BT_ID;
          EXCEPTION
          --找到银行缺失的记录
            WHEN NO_DATA_FOUND THEN
              INSERT INTO ACCOUNT_ERROR_DETAILS (ACCOUNT_TIME, BANK_ID, BT_ID, CUSTOMER_ID, ERROR_TYPE, PAY_ID)
                VALUES (IN_CHECK_DATE,IN_BANK_ID,pay_log_rec_.BT_ID,pay_log_rec_.CUSTOMER_ID,'0',pay_log_rec_.PAY_ID);
              absence_bank_count := absence_bank_count + 1;
              absence_bank_amount := absence_bank_amount + pay_log_rec_.PAY_AMOUNT;
        END;
      END LOOP;
      CLOSE pay_log_rec_cursor;
      DBMS_OUTPUT.PUT_LINE('[INFO]找到了' || absence_bank_count || '条银行缺失的缴费记录');
      OUT_RES := OUT_RES || '[INFO]找到了' || absence_bank_count || '条银行缺失的缴费记录' || ';';

      IF (bank_amount_ + absence_bank_amount) = enterprise_amount_ AND (bank_count_ + absence_bank_count) = enterprise_count_ THEN
        OUT_RES := OUT_RES || '[SUCCESS]对明细账操作完成' || ';';
      ELSE
        --情况二 未转账 已缴费 即公司缺失
        OPEN bt_rec_cursor;
        LOOP
          FETCH bt_rec_cursor INTO bt_rec_;
          EXIT WHEN bt_rec_cursor%NOTFOUND;
          BEGIN
            SELECT PAY_AMOUNT INTO pay_amount_ FROM PAY_LOG WHERE BT_ID = bt_rec_.BT_ID AND PAY_TYPE != '02';
            EXCEPTION
            --找到公司缺失的记录
              WHEN NO_DATA_FOUND THEN
                INSERT INTO ACCOUNT_ERROR_DETAILS (ACCOUNT_TIME, BANK_ID, BT_ID, CUSTOMER_ID, ERROR_TYPE)
                  VALUES (IN_CHECK_DATE,IN_BANK_ID,bt_rec_.BT_ID,bt_rec_.CUSTOMER_ID,'1');
                absence_enterprise_count := absence_enterprise_count + 1;
                absence_enterprise_amount := absence_enterprise_amount + bt_rec_.TRANSFER_AMOUNT;
          END;
        END LOOP;
        CLOSE pay_log_rec_cursor;
        OUT_RES := OUT_RES || '[INFO]找到了' || absence_enterprise_count || '条公司缺失的缴费记录' || ';';

        IF (bank_amount_ + absence_bank_amount) = (enterprise_amount_ + absence_enterprise_amount)
           AND (bank_count_ + absence_bank_count) = (enterprise_count_ + absence_enterprise_count) THEN
          OPEN pay_log_correct_rec_cursor;
          LOOP
            FETCH pay_log_correct_rec_cursor INTO pay_log_correct_rec_;
            EXIT WHEN pay_log_correct_rec_cursor%NOTFOUND;
            correct_count_ := correct_count_ + 1;
            INSERT INTO ACCOUNT_ERROR_DETAILS (ACCOUNT_TIME, BANK_ID, BT_ID, CUSTOMER_ID, ERROR_TYPE, PAY_ID)
               VALUES (IN_CHECK_DATE,IN_BANK_ID,pay_log_correct_rec_.BT_ID,pay_log_correct_rec_.CUSTOMER_ID,'2',pay_log_correct_rec_.PAY_ID);
          END LOOP;
          CLOSE pay_log_correct_rec_cursor;
          DBMS_OUTPUT.PUT_LINE('[INFO]找到了' || correct_count_ || '条冲正的缴费记录');
          OUT_RES := OUT_RES || '[SUCCESS]对明细账操作完成' || ';';
        ELSE
          DBMS_OUTPUT.PUT_LINE('[ERROR]对明细账操作出现异常，debug吧少年:<');
          OUT_RES := 'NO';
        END IF;
      END IF;
    END IF;
    COMMIT;
    EXCEPTION WHEN input_error THEN
      DBMS_OUTPUT.PUT_LINE('[ERROR]您输入的日期或银行ID有误');
      OUT_RES := 'NO';
  END CHECK_BY_DATE;
/

--对明细账
create PROCEDURE GET_ERROR_DETAIL(IN_BANK_ID IN BANK.BANK_ID%TYPE,
                                    IN_CHECK_DATE IN ACCOUNT_ERROR_DETAILS.ACCOUNT_TIME%TYPE,
                                    OUT_RES OUT VARCHAR2)AS
  CURSOR error_rec_cursor IS
    SELECT * FROM ACCOUNT_ERROR_DETAILS
        WHERE TO_DATE(ACCOUNT_TIME) = TO_DATE(IN_CHECK_DATE) AND BANK_ID = IN_BANK_ID;
  error_rec                ACCOUNT_ERROR_DETAILS%ROWTYPE;
  BEGIN
    OPEN error_rec_cursor;
    LOOP
      FETCH error_rec_cursor INTO error_rec;
      EXIT WHEN error_rec_cursor%NOTFOUND;
      OUT_RES := OUT_RES || error_rec.AE_ID || ',' || error_rec.CUSTOMER_ID || ',' || error_rec.ERROR_TYPE || ',' || error_rec.BT_ID
        || ',' || error_rec.PAY_ID || ';';
    END LOOP;
    CLOSE error_rec_cursor;
  END GET_ERROR_DETAIL;
/

--包和包体返回游标的存储过程
--返回余额表
create PACKAGE package_balance_cursor
AS

   TYPE balance_cursor IS REF CURSOR;--定义游标类型
   --定义存储过程
   PROCEDURE QUERY_BALANCE_BY_CUSTOMER_ID(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,balance_ OUT balance_cursor);

END package_balance_cursor;
/

create PACKAGE BODY package_balance_cursor AS

  PROCEDURE QUERY_BALANCE_BY_CUSTOMER_ID(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,balance_ OUT balance_cursor)
  AS
  BEGIN
      OPEN balance_ FOR
      SELECT * FROM BALANCE
      WHERE BALANCE.CUSTOMER_ID=IN_CUSTOMER_ID
      ORDER BY BALANCE.BALANCE_ID;
  END QUERY_BALANCE_BY_CUSTOMER_ID;

END package_balance_cursor;
/

--返回电费清单表
create or replace PACKAGE package_power_rate_list_cursor
AS

   TYPE power_rate_list_cursor IS REF CURSOR;--定义游标类型
   --定义存储过程
   PROCEDURE QUERY_LIST_BY_CUSTOMER_ID(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,power_rate_list_ OUT power_rate_list_cursor);

END package_power_rate_list_cursor;
/

create or replace PACKAGE BODY package_power_rate_list_cursor AS

  PROCEDURE QUERY_LIST_BY_CUSTOMER_ID(IN_CUSTOMER_ID IN CUSTOMER.CUSTOMER_ID%TYPE,power_rate_list_ OUT power_rate_list_cursor)
  AS
  BEGIN
      OPEN power_rate_list_ FOR
      SELECT * FROM POWER_RATE_LIST
      WHERE POWER_RATE_LIST.CUSTOMER_ID=IN_CUSTOMER_ID
      ORDER BY MT_DATE;
  END QUERY_LIST_BY_CUSTOMER_ID;

END package_power_rate_list_cursor;
/


