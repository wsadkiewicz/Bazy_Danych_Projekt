create or replace trigger trg_instruktor_id
before insert on instruktorzy_tab
for each row
begin
    if :new.id_instruktora is null then
        :new.id_instruktora := instruktor_seq.nextval;
    end if;
end;
/