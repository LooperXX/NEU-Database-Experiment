create table BANK
(
	BANK_ID VARCHAR2(9) not null
		primary key,
	BANK_NAME VARCHAR2(30) not null
)
/

create table ACCOUNT_TOTAL
(
	AT_ID NUMBER(9) not null
		primary key,
	ACCOUNT_DATE DATE not null,
	BANK_ID VARCHAR2(9) not null
		constraint ACCOUNT_TOTAL_BANK_BANK_ID_FK
			references BANK
				on delete cascade
				deferrable,
	BANK_COUNT NUMBER(9) not null,
	BANK_AMOUNT NUMBER(9,2) not null,
	ENTERPRISE_COUNT NUMBER(9) not null,
	ENTERPRISE_AMOUNT NUMBER(9,2) not null,
	IS_SUCCESS VARCHAR2(2)
)
/

create table CUSTOMER
(
	CUSTOMER_ID NUMBER(9) not null
		primary key,
	CUSTOMER_NAME VARCHAR2(30) not null,
	ADDRESS VARCHAR2(90) not null,
	BALANCE NUMBER(9,2) not null,
	PSWORD VARCHAR2(20) not null
)
/

create table ACCOUNT_ERROR_DETAILS
(
	AE_ID NUMBER(9) not null
		primary key,
	ACCOUNT_TIME DATE not null,
	BANK_ID VARCHAR2(9) not null
		constraint ERROR_DETAILS_BANK_ID_FK
			references BANK
				on delete cascade
				deferrable,
	BT_ID NUMBER(9) default NULL,
	CUSTOMER_ID NUMBER(9) not null
		constraint ERROR_DETAILS_CUSTOMER_ID_FK
			references CUSTOMER
				on delete cascade
				deferrable,
	ERROR_TYPE VARCHAR2(1) not null,
	PAY_ID NUMBER(9) default NULL
)
/



create table CODE_TABLE
(
	C_KEY VARCHAR2(30) not null
		primary key,
	C_VALUE VARCHAR2(9) not null
)
/

create table DEVICE
(
	DEVICE_ID NUMBER(9) not null
		primary key,
	CUSTOMER_ID NUMBER(9) not null
		constraint DEVICE_CUSTOMER_CUSTOMER_ID_FK
			references CUSTOMER
				on delete cascade
				deferrable,
	DEVICE_TYPE VARCHAR2(2) not null,
	DEVICE_NAME VARCHAR2(90) not null
)
/



create table PAY_LOG
(
	PAY_ID NUMBER(9) not null
		primary key,
	CUSTOMER_ID NUMBER(9) not null
		constraint PAY_LOG_CUSTOMER_ID_FK
			references CUSTOMER,
	PAY_TIME DATE not null,
	PAY_AMOUNT NUMBER(9,2) not null,
	PAY_TYPE VARCHAR2(2) not null,
	BANK_ID VARCHAR2(9) not null
		constraint PAY_LOG_BANK_BANK_ID_FK
			references BANK
				on delete cascade
				deferrable,
	BT_ID NUMBER(9) not null,
	NOTES VARCHAR2(200) default NULL
)
PARTITION BY LIST (PAY_TYPE)
(
   PARTITION PAY_LOG_FEE   VALUES ('01') TABLESPACE PROB_TS01,
   PARTITION PAY_LOG_CORRECT VALUES ('02') TABLESPACE PROB_TS02,
   PARTITION PAY_LOG_CORRECTED VALUES ('03') TABLESPACE PROB_TS03
)

/

create table POWER_RATE_LIST
(
	PR_ID NUMBER(9) not null
		primary key,
	DEVICE_ID NUMBER(9) not null
		constraint POWER_RATE_LIST_DEVICE_ID_FK
			references DEVICE,
	CUSTOMER_ID NUMBER(9) not null
		constraint POWER_RATE_LIST_CUSTOMER_ID_FK
			references CUSTOMER,
	MT_DATE DATE not null,
	BEGIN_NUMBER NUMBER(9) not null,
	END_NUMBER NUMBER(9) not null,
	BASIC_COST NUMBER(9,2) default 0.00 not null,
	ADDITIONAL_COST_1 NUMBER(9,2) default 0.00 not null,
	ADDITIONAL_COST_2 NUMBER(9,2) default 0.00 not null,
	PAID_FEE NUMBER(9,2) default 0.00 not null,
	ACTUAL_FEE NUMBER(9,2) default 0.00 not null,
	LATE_FEE NUMBER(9,2) default 0.00 not null,
	PAYABLE_DATE DATE not null,
	PAY_DATE DATE default NULL,
	ALREADY_FEE NUMBER(9,2) default 0.00 not null,
	PAY_STATE VARCHAR2(1) default 0 not null
)

PARTITION BY RANGE (PR_ID)
(
    PARTITION PR_PART1 VALUES LESS THAN (100000) TABLESPACE PR_TS01,
    PARTITION PR_PART2 VALUES LESS THAN (200000) TABLESPACE PR_TS02
)
/

create unique index POWER_DEVICE_ID_PAYABLE_DATE
	on POWER_RATE_LIST (DEVICE_ID, PAYABLE_DATE)
/

create table BANK_CARD
(
	CARD_ID NUMBER(16) not null
		primary key,
	BANK_ID VARCHAR2(9) not null
		constraint BANK_CARD_BANK_ID_FK
			references BANK
				on delete cascade
				deferrable,
	CUSTOMER_ID NUMBER(9) not null
		constraint BANK_CARD_CUSTOMER_ID_FK
			references CUSTOMER
				on delete cascade
				deferrable
)
/

create table BANK_TRANSFER_RECORD
(
	BT_ID NUMBER(9) not null
		primary key,
	BANK_ID VARCHAR2(9) not null
		constraint RECORD_BANK_BANK_ID_FK
			references BANK,
	CUSTOMER_ID NUMBER(9) not null
		constraint BANK_TRANSFER_CUSTOMER_ID_FK
			references CUSTOMER,
	TRANSFER_AMOUNT NUMBER(9,2) not null,
	TRANSFER_TIME DATE not null,
	CARD_ID NUMBER(16)
		constraint RECORD_BANK_CARD_ID_FK
			references BANK_CARD
)
/

create table BALANCE
(
	BALANCE_ID NUMBER(9) not null
		primary key,
	CUSTOMER_ID NUMBER(9) not null
		constraint BALANCE_CUSTOMER_ID_FK
			references CUSTOMER
				on delete cascade
				deferrable,
	BALANCE_TYPE VARCHAR2(1) not null,
	BALANCE_DELTA NUMBER(9,2) not null,
	PR_ID NUMBER(9),
	PAY_ID NUMBER(9),
	BT_ID NUMBER(9),
	TIME_CUR DATE not null
)
/

create table METER_READER
(
	MR_ID NUMBER(9) not null
		primary key,
	MR_NAME VARCHAR2(30) not null,
	PSWORD VARCHAR2(20) not null
)
/

create table METER_LOG
(
	MT_ID NUMBER(9) not null
		primary key,
	MT_DATE DATE not null,
	DEVICE_ID NUMBER(9) not null
		constraint METER_LOG_DEVICE_ID_FK
			references DEVICE,
	CUSTOMER_ID NUMBER(9) not null
		constraint METER_LOG_CUSTOMER_ID_FK
			references CUSTOMER,
	MT_NUMBER NUMBER(9) not null,
	MR_ID NUMBER(9)  not null
		constraint METER_LOG_READER_FK
			references METER_READER
				on delete cascade
				deferrable
)
PARTITION BY RANGE (MT_ID)
(
    PARTITION MT_PART1 VALUES LESS THAN (100000) TABLESPACE MT_TS01,
    PARTITION MT_PART2 VALUES LESS THAN (200000) TABLESPACE MT_TS02
)
/

create unique index METER_LOG_DEVICE_ID_MT_DATE
	on METER_LOG (DEVICE_ID, MT_DATE)
/

