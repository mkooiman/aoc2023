SET max_sp_recursion_depth =10000;

DROP TABLE if exists mappings;
create table mappings(name varchar(3) primary key, left_node varchar(3), right_node varchar(3) );

DROP TABLE if exists instructions;
create temporary table instructions(name varchar(1));

DROP PROCEDURE IF EXISTS parse_data;
CREATE PROCEDURE parse_data()
MODIFIES SQL DATA
BEGIN
    declare instruction_var text;
    select data into instruction_var from day_08 limit 1;
    call parse_mapping();

    parse_loop: loop
        insert into instructions (name) VALUES( substring(instruction_var,1,1));
        set instruction_var = substring(instruction_var,2);
        if length( instruction_var) = 0 then
            leave parse_loop;
        end if;
    end loop;
end;

DROP PROCEDURE IF EXISTS parse_mapping;
CREATE PROCEDURE parse_mapping()
MODIFIES SQL DATA
BEGIN
    insert into mappings(name, left_node,right_node)
    select
         REGEXP_REPLACE(data, '^.*([A-Z0-9]{3}).*([A-Z0-9]{3}).*([A-Z0-9]{3}).*$','$1'),
         REGEXP_REPLACE(data, '^.*([A-Z0-9]{3}).*([A-Z0-9]{3}).*([A-Z0-9]{3}).*$','$2'),
         REGEXP_REPLACE(data, '^.*([A-Z0-9]{3}).*([A-Z0-9]{3}).*([A-Z0-9]{3}).*$','$3')
     from day_08
     where data regexp '^.*([A-Z0-9]{3}).*([A-Z0-9]{3}).*([A-Z0-9]{3}).*$' ;
end;

call parse_data();

DROP FUNCTION IF EXISTS solve_01;
CREATE function solve_01(node varchar(3)) returns int
reads sql data
BEGIN
    DECLARE count int;
    DECLARE reopen_cursor bool;
    DECLARE instr varchar(1);
    DECLARE next_node varchar(3);

    DECLARE cur cursor for select name from instructions;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET reopen_cursor = TRUE;

    SET count =0;
    solve_loop: loop
        set reopen_cursor = false;
        open cur;
        instruction_loop: loop
            fetch cur into instr;
            if reopen_cursor then
                leave instruction_loop;
            end if;
            select (case
                when instr = 'L' then mappings.left_node
                else mappings.right_node
                end)
                into next_node from mappings where name = node;
            set count = count+1;
            set node = next_node;
            if substring(node,3,1) = 'Z' then
                leave solve_loop;
            end if;
        end loop;
        close cur;
    end loop;
    close cur;
    return count;
end;

select solve_01('22A');

DROP FUNCTION IF EXISTS GCD;
CREATE FUNCTION GCD(a bigINT, b bigINT) RETURNS bigINT
DETERMINISTIC
BEGIN
    DECLARE temp bigINT;
    WHILE b != 0 DO
        SET temp = a;
        SET a = b;
        SET b = temp % b;
    END WHILE;
    RETURN a;
END;

DROP FUNCTION IF EXISTS LCM;

CREATE FUNCTION LCM(a bigint, b bigint) RETURNS bigint
DETERMINISTIC
BEGIN
    IF a = 0 OR b = 0 THEN
        RETURN 0;
    ELSE
        RETURN ABS(a * b) / GCD(a, b);
    END IF;
END;

DROP FUNCTION IF EXISTS SCM;
CREATE FUNCTION SCM(numbers TEXT) RETURNS bigint
DETERMINISTIC
BEGIN
    DECLARE lcm, idx, nextNum, len bigint DEFAULT 0;
    DECLARE numList TEXT DEFAULT numbers;
    SET len = LENGTH(numList) - LENGTH(REPLACE(numList, ',', '')) + 1;

    IF len = 1 THEN
        RETURN numList;
    ELSE
        SET idx = 1;
        SET lcm = SUBSTRING_INDEX(numList, ',', 1);
        WHILE idx < len DO
            SET idx = idx + 1;
            SET nextNum = SUBSTRING_INDEX(SUBSTRING_INDEX(numList, ',', idx), ',', -1);
            SET lcm = LCM(lcm, nextNum);
        END WHILE;
        RETURN lcm;
    END IF;
END;

select SCM(group_concat(solve_01(name))) from mappings where substring(name, 3,1) = 'A' ;

