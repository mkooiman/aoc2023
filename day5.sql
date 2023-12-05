SET max_sp_recursion_depth =10000;

drop table if exists seeds;
create temporary table seeds( id int primary key auto_increment, seed_nr BIGINT);

drop table if exists seed_to_soil;
create temporary table seed_to_soil(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists soil_to_fertilizer;
create temporary table soil_to_fertilizer(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists fertilizer_to_water;
create temporary table fertilizer_to_water(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists water_to_light;
create temporary table water_to_light(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists light_to_temperature;
create temporary table light_to_temperature(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists temperature_to_humidity;
create temporary table temperature_to_humidity(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists humidity_to_location;
create temporary table humidity_to_location(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop procedure if exists parse_data;
create procedure parse_data()
MODIFIES SQL DATA
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE command text;

    DECLARE value1 bigint;
    DECLARE value2 bigint;
    DECLARE value3 bigint;

    DECLARE cur CURSOR FOR select data from day_05;

    DECLARE CONTINUE handler for NOT FOUND set done = true;
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
        elseif command = 'seed-to-soil map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into seed_to_soil VALUES(value1, value2, value3);
            end loop;
        elseif command = 'soil-to-fertilizer map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                 if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into soil_to_fertilizer VALUES(value1, value2, value3);
            end loop;
        elseif command = 'fertilizer-to-water map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                 if done then
                    leave parse_data;
                end if;

                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into fertilizer_to_water VALUES(value1, value2, value3);
            end loop;
        elseif command ='water-to-light map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into water_to_light VALUES(value1, value2, value3);
            end loop;
        elseif command ='light-to-temperature map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into light_to_temperature VALUES(value1, value2, value3);
            end loop;
        elseif command ='temperature-to-humidity map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into temperature_to_humidity VALUES(value1, value2, value3);
            end loop;
        elseif command = 'humidity-to-location map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into humidity_to_location VALUES(value1, value2, value3);
            end loop;
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

drop table if exists sln_01;
create temporary table sln_01 (seed_nr bigint, soil_nr bigint default -1, fertilizer_nr bigint default -1, water_nr bigint default -1, light_nr bigint default -1, temperature_nr bigint default -1, humidity_nr bigint default -1, location bigint default -1);

insert into sln_01 (seed_nr) select seed_nr from seeds;

update sln_01 s inner join seed_to_soil sts on sts.start_source <= s.seed_nr and  sts.start_source + sts.length >= s.seed_nr
    set s.soil_nr = (s.seed_nr + sts.start_dest-sts.start_source) where 1;

update sln_01 set soil_nr = seed_nr where soil_nr =-1;

update sln_01 s inner join soil_to_fertilizer sts on sts.start_source <= s.soil_nr and  sts.start_source + sts.length >= s.soil_nr
    set s.fertilizer_nr = s.soil_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set fertilizer_nr = soil_nr where fertilizer_nr =-1;

update sln_01 s inner join fertilizer_to_water sts on sts.start_source <= s.fertilizer_nr and  sts.start_source + sts.length >= s.fertilizer_nr
    set s.water_nr = s.fertilizer_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set water_nr = fertilizer_nr where water_nr =-1;

update sln_01 s inner join water_to_light sts on sts.start_source <= s.water_nr and  sts.start_source + sts.length >= s.water_nr
    set s.light_nr = s.water_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set light_nr = water_nr where light_nr =-1;

update sln_01 s inner join light_to_temperature sts on sts.start_source <= s.light_nr and  sts.start_source + sts.length >= s.light_nr
    set s.temperature_nr = s.light_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set temperature_nr = light_nr where temperature_nr=-1;

update sln_01 s inner join temperature_to_humidity sts on sts.start_source <= s.temperature_nr and  sts.start_source + sts.length >= s.temperature_nr
    set s.humidity_nr = s.temperature_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set humidity_nr = temperature_nr where humidity_nr=-1;

update sln_01 s inner join humidity_to_location sts on sts.start_source <= s.humidity_nr and  sts.start_source + sts.length >= s.humidity_nr
    set s.location = s.humidity_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set location = humidity_nr where location=-1;

SET max_sp_recursion_depth =10000;

drop table if exists seeds;
create temporary table seeds( id int primary key auto_increment, seed_nr BIGINT);

drop table if exists seed_to_soil;
create temporary table seed_to_soil(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists soil_to_fertilizer;
create temporary table soil_to_fertilizer(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists fertilizer_to_water;
create temporary table fertilizer_to_water(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists water_to_light;
create temporary table water_to_light(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists light_to_temperature;
create temporary table light_to_temperature(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists temperature_to_humidity;
create temporary table temperature_to_humidity(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists humidity_to_location;
create temporary table humidity_to_location(start_dest BIGINT, start_source BIGINT, length BIGINT);


drop procedure if exists parse_data;
create procedure parse_data()
MODIFIES SQL DATA
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE command text;

    DECLARE value1 bigint;
    DECLARE value2 bigint;
    DECLARE value3 bigint;

    DECLARE cur CURSOR FOR select data from day_05;

    DECLARE CONTINUE handler for NOT FOUND set done = true;
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
        elseif command = 'seed-to-soil map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into seed_to_soil VALUES(value1, value2, value3);
            end loop;
        elseif command = 'soil-to-fertilizer map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                 if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into soil_to_fertilizer VALUES(value1, value2, value3);
            end loop;
        elseif command = 'fertilizer-to-water map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                 if done then
                    leave parse_data;
                end if;

                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into fertilizer_to_water VALUES(value1, value2, value3);
            end loop;
        elseif command ='water-to-light map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into water_to_light VALUES(value1, value2, value3);
            end loop;
        elseif command ='light-to-temperature map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into light_to_temperature VALUES(value1, value2, value3);
            end loop;
        elseif command ='temperature-to-humidity map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into temperature_to_humidity VALUES(value1, value2, value3);
            end loop;
        elseif command = 'humidity-to-location map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into humidity_to_location VALUES(value1, value2, value3);
            end loop;
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
select *, sts.start_source-sts.start_dest as sts_offset from seeds s
    inner join seed_to_soil sts on sts.start_source <= s.seed_nr and  sts.start_source + sts.length >= s.seed_nr;

drop table sln_01;
create temporary table sln_01 (seed_nr bigint, soil_nr bigint default -1, fertilizer_nr bigint default -1, water_nr bigint default -1, light_nr bigint default -1, temperature_nr bigint default -1, humidity_nr bigint default -1, location bigint default -1);

insert into sln_01 (seed_nr) select seed_nr from seeds;

update sln_01 s inner join seed_to_soil sts on sts.start_source <= s.seed_nr and  sts.start_source + sts.length >= s.seed_nr
    set s.soil_nr = (s.seed_nr + sts.start_dest-sts.start_source) where 1;

update sln_01 set soil_nr = seed_nr where soil_nr =-1;

update sln_01 s inner join soil_to_fertilizer sts on sts.start_source <= s.soil_nr and  sts.start_source + sts.length >= s.soil_nr
    set s.fertilizer_nr = s.soil_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set fertilizer_nr = soil_nr where fertilizer_nr =-1;SET max_sp_recursion_depth =10000;

drop table if exists seeds;
create temporary table seeds( id int primary key auto_increment, seed_nr BIGINT);

drop table if exists seed_to_soil;
create temporary table seed_to_soil(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists soil_to_fertilizer;
create temporary table soil_to_fertilizer(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists fertilizer_to_water;
create temporary table fertilizer_to_water(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists water_to_light;
create temporary table water_to_light(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists light_to_temperature;
create temporary table light_to_temperature(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists temperature_to_humidity;
create temporary table temperature_to_humidity(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop table if exists humidity_to_location;
create temporary table humidity_to_location(start_dest BIGINT, start_source BIGINT, length BIGINT);

drop procedure if exists parse_data;
create procedure parse_data()
MODIFIES SQL DATA
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE command text;

    DECLARE value1 bigint;
    DECLARE value2 bigint;
    DECLARE value3 bigint;

    DECLARE cur CURSOR FOR select data from day_05;

    DECLARE CONTINUE handler for NOT FOUND set done = true;
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
        elseif command = 'seed-to-soil map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into seed_to_soil VALUES(value1, value2, value3);
            end loop;
        elseif command = 'soil-to-fertilizer map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                 if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into soil_to_fertilizer VALUES(value1, value2, value3);
            end loop;
        elseif command = 'fertilizer-to-water map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                 if done then
                    leave parse_data;
                end if;

                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into fertilizer_to_water VALUES(value1, value2, value3);
            end loop;
        elseif command ='water-to-light map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into water_to_light VALUES(value1, value2, value3);
            end loop;
        elseif command ='light-to-temperature map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into light_to_temperature VALUES(value1, value2, value3);
            end loop;
        elseif command ='temperature-to-humidity map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into temperature_to_humidity VALUES(value1, value2, value3);
            end loop;
        elseif command = 'humidity-to-location map' then
            sts: LOOP
                fetch cur into input;

                if input is null then
                    leave sts;
                end if;
                if done then
                    leave parse_data;
                end if;
                SET value1 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$1');
                SET value2 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$2');
                SET value3 = regexp_replace(input, '^([0-9]+)[^0-9]([0-9]+)[^0-9]([0-9]+)$','$3');

                insert into humidity_to_location VALUES(value1, value2, value3);
            end loop;
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
select *, sts.start_source-sts.start_dest as sts_offset from seeds s
    inner join seed_to_soil sts on sts.start_source <= s.seed_nr and  sts.start_source + sts.length >= s.seed_nr;

drop table sln_01;
create temporary table sln_01 (seed_nr bigint, soil_nr bigint default -1, fertilizer_nr bigint default -1, water_nr bigint default -1, light_nr bigint default -1, temperature_nr bigint default -1, humidity_nr bigint default -1, location bigint default -1);

insert into sln_01 (seed_nr) select seed_nr from seeds;

update sln_01 s inner join seed_to_soil sts on sts.start_source <= s.seed_nr and  sts.start_source + sts.length >= s.seed_nr
    set s.soil_nr = (s.seed_nr + sts.start_dest-sts.start_source) where 1;

update sln_01 set soil_nr = seed_nr where soil_nr =-1;

update sln_01 s inner join soil_to_fertilizer sts on sts.start_source <= s.soil_nr and  sts.start_source + sts.length >= s.soil_nr
    set s.fertilizer_nr = s.soil_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set fertilizer_nr = soil_nr where fertilizer_nr =-1;


update sln_01 s inner join fertilizer_to_water sts on sts.start_source <= s.fertilizer_nr and  sts.start_source + sts.length >= s.fertilizer_nr
    set s.water_nr = s.fertilizer_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set water_nr = fertilizer_nr where water_nr =-1;

update sln_01 s inner join water_to_light sts on sts.start_source <= s.water_nr and  sts.start_source + sts.length >= s.water_nr
    set s.light_nr = s.water_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set light_nr = water_nr where light_nr =-1;

update sln_01 s inner join light_to_temperature sts on sts.start_source <= s.light_nr and  sts.start_source + sts.length >= s.light_nr
    set s.temperature_nr = s.light_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set temperature_nr = light_nr where temperature_nr=-1;

update sln_01 s inner join temperature_to_humidity sts on sts.start_source <= s.temperature_nr and  sts.start_source + sts.length >= s.temperature_nr
    set s.humidity_nr = s.temperature_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set humidity_nr = temperature_nr where humidity_nr=-1;

update sln_01 s inner join humidity_to_location sts on sts.start_source <= s.humidity_nr and  sts.start_source + sts.length >= s.humidity_nr
    set s.location = s.humidity_nr + sts.start_dest-sts.start_source where 1;

update sln_01 set location = humidity_nr where location=-1;
select min(location) as answer1 from sln_01;




