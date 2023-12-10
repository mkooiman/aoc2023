SET max_sp_recursion_depth =10000;

DROP TABLE IF EXISTS ans1;
CREATE TABLE ans1(id int auto_increment primary key , parent int null default null, data TEXT, level int);

DROP PROCEDURE IF EXISTS parse_data;
CREATE PROCEDURE parse_data()
MODIFIES SQL DATA
BEGIN
    DECLARE line int;
    set line = 0;
    insert into ans1(data, level, id) select data, 0, line from day_10;
end;

DROP PROCEDURE IF EXISTS solve_level;
CREATE PROCEDURE solve_level( out results_processed int)
MODIFIES SQL DATA
BEGIN
    DECLARE done bool;
    DECLARE parentId, lastNr int;
    DECLARE line TEXT;
    DECLARE cur CURSOR FOR select data, id from ans1 where level = 0 and data NOT REGEXP '^[0 ]+$';
    DECLARE CONTINUE handler for NOT FOUND set done = true;

    SET results_processed=0;
    open cur;
    solve_loop: LOOP
        fetch cur into line, parentId;
        if done then
            leave solve_loop;
        end if;
        CALL make_delta_lines(line, 1, parentId, lastNr);

        update ans1 set data = CONCAT(line,' ', regexp_replace(line, '.* ([\\-0-9]+)$', '$1') + (lastNr)) where id = parentId;
        SET results_processed = results_processed+1;
    end loop;
end;

DROP PROCEDURE IF EXISTS make_delta_lines;
CREATE PROCEDURE make_delta_lines(line text, level_arg int, parent_arg int, out return_value int)
MODIFIES SQL DATA
BEGIN
    DECLARE substr_offset, num1, num2, returned_number, append_value int;
    DECLARE first_loop_done bool;
    DECLARE result text;

    set result ='';
    process_loop: loop
        if char_length(trim(line))=0 then
            leave process_loop;
        end if;

        SET substr_offset = regexp_instr(line, '^([\\-0-9]+) ',1,1,1);
        SET num2 = regexp_replace(line, '^([\\-0-9]+)\\s.*','$1');

        set line = substring(line, substr_offset);
        if first_loop_done then
            SET append_value = num2-num1;
            set result = CONCAT(result, append_value, ' ');
        end if;
        set num1 = num2;
        set first_loop_done=true;
    end loop;
    if(result NOT REGEXP '^[0 ]+$') then
        call make_delta_lines(result, level_arg+1,parent_arg, returned_number);
        set return_value = (append_value+returned_number);
        insert into ans1(data, level, parent) VALUES (CONCAT(result,return_value) , level_arg, parent_arg);
    else
        insert into ans1(data, level, parent) VALUES (result, level_arg, parent_arg);
        set return_value = 0;
    end if;
end;

call parse_data();
call solve_level( @results);

select sum(regexp_replace(data, '.* ([\\-0-9]+)$', '$1')) as answer1 from ans1 where level=0;

drop function if exists reverse_data;
create function reverse_data(data text) returns text
DETERMINISTIC
BEGIN
    DECLARE result text;
    set result = '';
    while char_length(trim(data)) > 0 do
        set result = concat(regexp_replace(data, '^ ?([\\-0-9]+) ?(.*)$', '$1'),' ', result);
        set data = regexp_replace(data, '^([\\-0-9]+) ?(.*)$', '$2');
    end while;

    return trim(result);
end;
delete from ans1 where level<>0;
update ans1 set data = reverse_data(data);
call solve_level(@results);
select sum(regexp_replace(data, '.* ([\\-0-9]+)$', '$1')) as answer2 from ans1 where level=0;
