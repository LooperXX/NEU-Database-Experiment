create trigger AT_ID_TRIGGER
	before insert
	on ACCOUNT_TOTAL
	for each row when (NEW.AT_ID is null)
begin
	  select AT_ID_SEQUENCE.nextval into :NEW.AT_ID from dual;
	end;
/

create trigger AE_ID_TRIGGER
	before insert
	on ACCOUNT_ERROR_DETAILS
	for each row when (NEW.AE_ID is null)
begin
	  select AE_ID_SEQUENCE.nextval into :NEW.AE_ID from dual;
	end;
/

create trigger CUSTOMER_ID_TRIGGER
	before insert
	on CUSTOMER
	for each row when (NEW.CUSTOMER_ID is null)
begin
	  select CUSTOMER_ID_SEQUENCE.nextval into :NEW.CUSTOMER_ID from dual;
	end;
/

create trigger DEVICE_ID_TRIGGER
	before insert
	on DEVICE
	for each row when (NEW.DEVICE_ID is null)
begin
	  select DEVICE_ID_SEQUENCE.nextval into :NEW.DEVICE_ID from dual;
	end;
/

create trigger PAY_ID_TRIGGER
	before insert
	on PAY_LOG
	for each row when (NEW.PAY_ID is null)
begin
	  select PAY_ID_SEQUENCE.nextval into :NEW.PAY_ID from dual;
	end;
/

create trigger PR_ID_TRIGGER
	before insert
	on POWER_RATE_LIST
	for each row when (NEW.PR_ID is null)
begin
	  select PR_ID_SEQUENCE.nextval into :NEW.PR_ID from dual;
	end;
/

create trigger BT_ID_TRIGGER
	before insert
	on BANK_TRANSFER_RECORD
	for each row when (NEW.BT_ID is null)
begin
	  select BT_ID_SEQUENCE.nextval into :NEW.BT_ID from dual;
	end;
/

create trigger CARD_ID_TRIGGER
	before insert
	on BANK_CARD
	for each row when (NEW.CARD_ID is null)
begin
	  select CARD_ID_SEQUENCE.nextval into :NEW.CARD_ID from dual;
	end;
/

create trigger BALANCE_ID_TRIGGER
	before insert
	on BALANCE
	for each row when (NEW.BALANCE_ID is null)
begin
  select BALANCE_ID_SEQUENCE.nextval into :NEW.BALANCE_ID from dual;
end;
/

create trigger MT_ID_TRIGGER
	before insert
	on METER_LOG
	for each row when (NEW.MT_ID is null)
begin
	  select MT_ID_SEQUENCE.nextval into :NEW.MT_ID from dual;
	end;
/
