SET max_sp_recursion_depth =10000;

drop table if exists day_03_parsed;
create table day_03_parsed(id int primary key auto_increment, value text, start int, end int, row_nr int, is_numeric bool);

drop procedure if exists parse_data;
CREATE PROCEDURE parse_data()
begin
    DECLARE done bool;
    DECLARE input text;
    DECLARE row_nr int;
    DECLARE cur CURSOR FOR SELECT data FROM day_03;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET row_nr = 1;
    open cur;
    read_loop: LOOP
        FETCH cur INTO input;
        if done then
            leave read_loop;
        end if;
        call iterate_substrings( input, 1, row_nr);
        SET row_nr = row_nr + 1;
    end loop;
end;

drop procedure if exists iterate_substrings;
CREATE PROCEDURE iterate_substrings(data text, start_index int, row_nr_arg int)
begin
    declare start int;
    declare end int;
    declare value text;
    read_loop: LOOP

        SET start = regexp_instr(data, '([0-9]+|[^0-9^\.]+)',start_index);
        SET end = regexp_instr(data, '([0-9]+|[^0-9^\.]+)', start_index,1,1);
        set value = regexp_substr(data, '([0-9]+|[^0-9^\.]+)',start_index);
        if start = 0 or end = 0 then
            leave read_loop;
        end if;

        insert into day_03_parsed (value, start, end, row_nr, is_numeric) VALUES(value, start, end, row_nr_arg, value regexp('^[0-9]+$'));

        set start_index = end;
        if start_index >= length(data) then
            leave read_loop;
        end if;
    end loop;
end;

call parse_data();

select sum(s.value) as day_03_answer_1 from day_03_parsed s
    inner join (select id, row_nr, start, end, value from day_03_parsed where is_numeric = false) s2
        on (abs(s2.row_nr - s.row_nr) <= 1 and s.start-1 <= s2.start and s.end+1 >= s2.end)
        where s.is_numeric = true ;

select sum(substr(vals from 1 for locate(',',vals)-1)* substr(vals, locate(',',vals)+1)) as day_03_answer_2
from(
    select s.*, group_concat(s2.value) as vals  from day_03_parsed s
        left join (select id, row_nr, start, end, value as value from day_03_parsed where is_numeric = true) s2
            on (abs(s2.row_nr - s.row_nr) <= 1 and s2.start-1 <= s.start and s2.end+1 >= s.end)
        where s.value = '*' group by s.id having count(s2.id)=2) as source;
