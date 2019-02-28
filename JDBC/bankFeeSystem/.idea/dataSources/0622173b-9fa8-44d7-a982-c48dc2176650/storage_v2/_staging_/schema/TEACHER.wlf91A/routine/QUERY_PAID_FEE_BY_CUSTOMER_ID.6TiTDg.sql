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

