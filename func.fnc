create or replace function fun32 (
    data in date
) return varchar2 as
begin
    return to_char(data, 'Day', 'nls_date_language = polish');
end fun32;