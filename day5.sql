SET max_sp_recursion_depth =10000;

drop table if exists seeds;
create temporary table seeds( id int primary key auto_increment, seed_nr BIGINT);

drop table if exists mappings;
create temporary table mappings(start_dest BIGINT, start_source BIGINT, length BIGINT, level int);

drop procedure if exists parse_data;
create procedure parse_data()
MODIFIES SQL DATA
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE command text;
    DECLARE level int;

    DECLARE value1 bigint;
    DECLARE value2 bigint;
    DECLARE value3 bigint;

    DECLARE cur CURSOR FOR select data from day_05;
    DECLARE CONTINUE handler for NOT FOUND set done = true;

    SET level = 0;

    open cur;
    parse_data: LOOP
        fetch cur into input;

        if input is null then
             fetch cur into input;
        end if;
        if done then
            leave parse_data;
        end if;
        set command = substr(input from 1 for locate(':', input)-1);
        if command = 'seeds' then
            call parse_seed(input);
        else
            sts: LOOP
                fetch cur into input;
                if done then
                    leave parse_data;
                end if;

                if input is null then
                    leave sts;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into mappings VALUES(value1, value2, value3, level);
            end loop;
            SET level = level + 1;
        end if;


    end loop;

    close cur;
end;

drop PROCEDURE if exists parse_seed;
CREATE PROCEDURE parse_seed( data text)
MODIFIES SQL DATA
BEGIN
    DECLARE current_number bigint;
    DECLARE current_number_end int;
    SET data = substr(data from locate(':', data)+1);
    read_loop: LOOP
        SET current_number_end = regexp_instr(data,'([0-9]+)',1,1,1);
        if current_number_end = 0 then
           leave read_loop;
        end if;
        SET current_number = regexp_replace(data,'^[^0-9]*([0-9]+).*$', '$1');
        insert into seeds (seed_nr) VALUES (current_number);
        SET data = substr(data, current_number_end+1);

    end loop;
end;


call parse_data();
select * from mappings;
drop table if exists sln_01;
create temporary table sln_01 (seed_nr bigint, soil_nr bigint default -1, fertilizer_nr bigint default -1, water_nr bigint default -1, light_nr bigint default -1, temperature_nr bigint default -1, humidity_nr bigint default -1, location bigint default -1);

insert into sln_01 (seed_nr) select seed_nr from seeds;

update sln_01 s inner join mappings sts on sts.start_source <= s.seed_nr and  sts.start_source + sts.length >= s.seed_nr and level =0
    set s.soil_nr = (s.seed_nr + sts.start_dest-sts.start_source) where 1;

update sln_01 set soil_nr = seed_nr where soil_nr =-1;

update sln_01 s inner join mappings sts on sts.start_source <= s.soil_nr and  sts.start_source + sts.length >= s.soil_nr and level =1
    set s.fertilizer_nr = s.soil_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set fertilizer_nr = soil_nr where fertilizer_nr =-1;

update sln_01 s inner join mappings sts on sts.start_source <= s.fertilizer_nr and  sts.start_source + sts.length >= s.fertilizer_nr  and level =2
    set s.water_nr = s.fertilizer_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set water_nr = fertilizer_nr where water_nr =-1;

update sln_01 s inner join mappings sts on sts.start_source <= s.water_nr and  sts.start_source + sts.length >= s.water_nr and level =3
    set s.light_nr = s.water_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set light_nr = water_nr where light_nr =-1;

update sln_01 s inner join mappings sts on sts.start_source <= s.light_nr and  sts.start_source + sts.length >= s.light_nr and level =4
    set s.temperature_nr = s.light_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set temperature_nr = light_nr where temperature_nr=-1;

update sln_01 s inner join mappings sts on sts.start_source <= s.temperature_nr and  sts.start_source + sts.length >= s.temperature_nr  and level =5
    set s.humidity_nr = s.temperature_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set humidity_nr = temperature_nr where humidity_nr=-1;

update sln_01 s inner join mappings sts on sts.start_source <= s.humidity_nr and  sts.start_source + sts.length >= s.humidity_nr  and level =6
    set s.location = s.humidity_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set location = humidity_nr where location=-1;


drop table if exists sln_02;
create temporary table sln_02(range_start bigint, length bigint, level int);

drop procedure if exists parse_seed_02;
create procedure parse_seed_02(data text)
modifies sql data
begin
    DECLARE current_number bigint;
    DECLARE current_number_end int;
    DECLARE current_length bigint;
    SET data = substr(data from locate(':', data)+1);

    read_loop: LOOP
        SET current_number_end = regexp_instr(data,'([0-9]+) ([0-9]+)',1,1,1);

        if current_number_end = 0 then
           leave read_loop;
        end if;

        SET current_number = regexp_replace(data,'^[^0-9]*([0-9]+)[^0-9]+([0-9]+).*$', '$1');
        SET current_length = regexp_replace(data,'^[^0-9]*([0-9]+)[^0-9]+([0-9]+).*$', '$2');
        insert into sln_02 (range_start, length, level) VALUES(current_number, current_length, 0);
        set data = substr(data from current_number_end);
    end loop;
end;

select data into @seed from day_05 limit 1;


drop procedure if exists solve_02;
create procedure solve_02()
modifies sql data
begin
    truncate sln_02;
    call parse_seed_02(@seed);
    call solve_02_1(1);
    call solve_02_1(2);
    call solve_02_1(3);
    call solve_02_1(4);
    call solve_02_1(5);
    call solve_02_1(6);
    call solve_02_1(7);

end;


drop procedure if exists solve_02_1;
create procedure solve_02_1(level_arg int)
modifies sql data
begin
    declare done bool;
    declare range_start bigint;
    declare range_length bigint;

    declare cur cursor for select sln_02.range_start, sln_02.length from sln_02 where level = level_arg -1;
    declare continue handler for NOT FOUND SET done = true;

    open cur;

    process_loop: loop
        fetch cur into range_start, range_length;
        if done then
            leave process_loop;
        end if;
        call solve_02_2(range_start, range_length, level_arg);


    end loop;
end;

drop procedure if exists solve_02_2;
create procedure solve_02_2(range_start_arg bigint, range_length_arg bigint, level_arg int)
modifies sql data
begin
    declare done bool;
    declare mapping_src bigint;
    declare mapping_dst bigint;
    DECLARE range1_start bigint;
    DECLARE range1_length bigint;
    DECLARE range2_start bigint;
    DECLARE range2_length bigint;
    declare mapping_length bigint;
    declare cur cursor for select start_source, start_dest, length from mappings m
              where range_start_arg <= start_source + length - 1 and start_source <= range_start_arg + range_length_arg - 1
        and m.level = level_arg-1 order by start_source limit 1;
    declare continue handler for NOT FOUND SET done = true;

    open cur;

    fetch cur into mapping_src, mapping_dst, mapping_length;

    if done then
        insert into sln_02(range_start, length, level)  VALUES(range_start_arg, range_length_arg,level_arg);
        close cur;
    elseif (mapping_src <= range_start_arg and (mapping_src + mapping_length >= range_start_arg + range_length_arg)) then
        insert into sln_02 (range_start, length, level) VALUES(range_start_arg + (mapping_dst - mapping_src), range_length_arg,level_arg);
        close cur;
    elseif mapping_src > range_start_arg then
        set range1_start = range_start_arg;
        set range1_length = mapping_src - range_start_arg;
        set range2_start = mapping_src;
        set range2_length = range_length_arg - range1_length;
        close cur;
        call solve_02_2(range1_start, range1_length, level_arg);
        call solve_02_2(range2_start, range2_length, level_arg);

    elseif mapping_src+mapping_length < range_start_arg+range_length_arg then
        set range1_start = range_start_arg;
        set range1_length = least(mapping_src + mapping_length, range_start_arg + range_length_arg) - range_start_arg;
        set range2_start = mapping_src + mapping_length;
        set range2_length = range_start_arg + range_length_arg - range2_start;

        close cur;
        call solve_02_2(range1_start, range1_length, level_arg);
        call solve_02_2(range2_start, range2_length, level_arg);
    end if;
end;


call solve_02();

select min(range_start) as answer2 from sln_02 where level = 7;

