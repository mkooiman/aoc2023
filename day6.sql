SET max_sp_recursion_depth =10000;

DROP table if exists race_times;
CREATE TEMPORARY TABLE race_times(time bigint, distance bigint, ways_to_beat int default 0);

drop procedure if exists parse_data;
create procedure parse_data()
MODIFIES SQL DATA
BEGIN
    DECLARE time_str text;
    DECLARE dist_str text;
    DECLARE current_time_val int;
    DECLARE current_time_end int;
    DECLARE current_dist_val int;
    DECLARE current_dist_end int;

    select data into time_str from day_06 limit 1;
    select data into dist_str from day_06 LIMIT 1 OFFSET 1;

    SET time_str = substr(time_str from locate(':', time_str)+1);
    SET dist_str = substr(dist_str from locate(':', dist_str)+1);

    read_loop: LOOP
        SET current_time_end = regexp_instr(time_str,'([0-9]+)',1,1,1);
        SET current_dist_end = regexp_instr(dist_str,'([0-9]+)',1,1,1);
        if current_time_end = 0 then
           leave read_loop;
        end if;

        SET current_time_val = regexp_replace(time_str,'^[^0-9]*([0-9]+).*$', '$1');
        SET current_dist_val = regexp_replace(dist_str,'^[^0-9]*([0-9]+).*$', '$1');

        insert into race_times (time, distance) VALUES (current_time_val, current_dist_val);

        SET time_str = substr(time_str, current_time_end+1);
        SET dist_str = substr(dist_str, current_dist_end+1);

    end loop;
end;

call parse_data();

drop function if exists find_lower_bound;
create function find_lower_bound(time_arg bigint, dist_arg bigint) RETURNS int
 DETERMINISTIC
begin
    DECLARE current_nr bigint;
    SET current_nr = 1;
    LOOP
        if current_nr *(time_arg - current_nr) > dist_arg then
            return current_nr;
        end if;
        if current_nr>time_arg then
            return -1;
        end if;
        SET current_nr = current_nr+1;
    end loop;
end;


drop function if exists find_upper_bound;
create function find_upper_bound(time_arg bigint, dist_arg bigint) RETURNS int
DETERMINISTIC
begin
    DECLARE current_nr bigint;
    SET current_nr = time_arg - 1;
    LOOP
        if current_nr * (time_arg - current_nr) > dist_arg then
            return current_nr;
        end if;
        if current_nr >= time_arg then
            return -1;
        end if;
        SET current_nr = current_nr-1;
    end loop;
end;

select round(exp(sum(ln(find_upper_bound(time, distance)- find_lower_bound(time, distance )+1)))) as answer1 from race_times;

drop procedure if exists parse_data_2;
create procedure parse_data_2()
MODIFIES SQL DATA
BEGIN
    DECLARE time_str text;
    DECLARE dist_str text;
    select data into time_str from day_06 limit 1;
    select data into dist_str from day_06 LIMIT 1 OFFSET 1;
    SET time_str = regexp_replace(time_str, '[^0-9]','');
    SET dist_str = regexp_replace(dist_str, '[^0-9]','');

    insert into race_times (time, distance) VALUES (time_str, dist_str);

end;
truncate race_times;
call parse_data_2();
select find_upper_bound(time, distance)- find_lower_bound(time, distance ) +1 as answer2 from race_times;

