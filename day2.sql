SET max_sp_recursion_depth =10000;

drop table if exists day_02_game;
create temporary table day_02_game (id int);
drop table if exists day_02_round;
create temporary table day_02_round( id int key auto_increment, red int, green int, blue int );

drop table if exists day_02_game_round;
create temporary table day_02_game_round (game_id int, round_id int);


drop PROCEDURE if exists parse_game;


CREATE PROCEDURE parse_game(data TEXT)
MODIFIES SQL DATA
BEGIN
    DECLARE rest TEXT;

    INSERT INTO day_02_game (id) VALUES (regexp_replace(data, '^Game ([0-9]+):.*', '$1'));
    SET rest = SUBSTR(data, LOCATE(':', data) + 1);
    call parse_round(regexp_replace(data, '^Game ([0-9]+):.*', '$1'), rest);
END;

drop PROCEDURE if exists parse_round;

CREATE PROCEDURE parse_round ( game int, data text )
MODIFIES SQL DATA
   parse_round_label: begin
        DECLARE rest text;
        DECLARE index1 int;
        DECLARE target text;
        DECLARE red int;
        DECLARE green int;
        declare blue int;

        SET index1  = LOCATE( ';',data);
        if(index1 = 0 ) then
            SET target = data;
        else
            SET target = SUBSTRING(data from 1 for index1);
        end if;

        SET rest = SUBSTRING( data from index1+1);

        if length(data)>3 then

            if LOCATE('red', target )>0 then
                SET red = REGEXP_REPLACE(target, '.*[^0-9]+([0-9]+) red.*','$1');
            else
                set red =0;
            end if;

            if LOCATE('green', target)>0 then
                SET green = REGEXP_REPLACE(target, '.*[^0-9]+([0-9]+) green.*','$1');
            else
                set green = 0;
            end if;

            if LOCATE('blue', target)>0 then
                SET blue = REGEXP_REPLACE(target, '.*[^0-9]+([0-9]+) blue.*','$1');
            else
                SET blue = 0;
            end if;
            insert into day_02_round (red, green, blue) values (red, green, blue);
            insert into day_02_game_round(game_id, round_id) values(game, LAST_INSERT_ID());

            if( index1 <> 0) then
                call parse_round(game, rest);
            end if;
        end if;

END;

drop procedure if exists IterateAndCallProcedure;
CREATE PROCEDURE IterateAndCallProcedure()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE aParam text;
    DECLARE cur CURSOR FOR SELECT data FROM day_02;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO aParam;
        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL parse_game(aParam);
    END LOOP;

    CLOSE cur;
END;

call IterateAndCallProcedure;

select * from day_02_game;
select * from day_02_round;
select * from day_02_game_round;


SELECT sum(id) as answer_day_02_pt1 from day_02_game where id not in (
    select game_id from day_02_game_round gr inner join day_02_round r on r.id = gr.round_id
                   where green > 13 or red> 12 or blue >14
    );

select sum(powers) from (select max(red) * max(green) * max(blue) as powers from day_02_round inner join day_02_game_round d02gr on day_02_round.id = d02gr.round_id
group by game_id) as p;