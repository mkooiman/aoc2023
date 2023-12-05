SET max_sp_recursion_depth =10000;

drop table if exists day_04_card_numbers;
create table day_04_card_numbers(id int auto_increment primary key , card_nr int, nr int, is_card bool);

drop procedure if exists parse_data;
CREATE PROCEDURE parse_data()
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE cur CURSOR FOR SELECT data FROM day_04;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO input;
        if done then
            leave read_loop;
        end if;
        call parse_record(input);
    end loop;
    close cur;
end;

DROP PROCEDURE if exists parse_record;
CREATE PROCEDURE parse_record(data text)
BEGIN
    DECLARE card_nr int;
    DECLARE read_idx int;
    DECLARE card_data text;
    DECLARE draw_data text;

    SET card_nr = regexp_replace(data,'^[^0-9]+([0-9]+):.*$', '$1');
    SET read_idx = locate(':',data);
    SET card_data = substring(data from read_idx for locate('|',data)-read_idx);
    SET draw_data = substring(data from locate('|',data) for LENGTH(data)-card_data);

    call parse_numbers(card_data, card_nr,true);
    call parse_numbers(draw_data, card_nr, false);
end;

DROP PROCEDURE if exists parse_numbers;
CREATE PROCEDURE  parse_numbers(data text, card_nr_arg int, is_card_arg bool)
MODIFIES SQL DATA
BEGIN
    DECLARE current_number int;
    DECLARE current_number_end int;

    read_loop: LOOP
        SET current_number_end = regexp_instr(data,'([0-9]+)',1,1,1);
        if current_number_end = 0 then
           leave read_loop;
        end if;

        SET current_number = regexp_replace(data,'[^0-9]*([0-9]+).*$', '$1');
        insert into day_04_card_numbers (card_nr, nr, is_card) VALUES (card_nr_arg, current_number, is_card_arg);
        SET data = substr(data, current_number_end+1);

    end loop;

END;

call parse_data();

select SUM(score) as day04_answer_1 from( select pow(2,count(id)-1) as score from day_04_card_numbers q
    inner join (select card_nr, nr from day_04_card_numbers where is_card = false) subq on q.card_nr = subq.card_nr and q.nr = subq.nr
 where is_card = true GROUP BY q.card_nr) sq1;

DROP TABLE IF EXISTS cards;
CREATE TABLE cards(card_nr int, nr_cards int default 1);

insert into cards (card_nr) select distinct card_nr from day_04_card_numbers;

DROP PROCEDURE IF EXISTS process_pt2;
CREATE PROCEDURE process_pt2()
MODIFIES SQL DATA
BEGIN
    DECLARE done bool;
    DECLARE current_card int;
    DECLARE current_wins int;
    DECLARE nr_card_var int;
    DECLARE cur CURSOR FOR
        select q.card_nr, count(id) as score from day_04_card_numbers q
            inner join (select card_nr, nr from day_04_card_numbers where is_card = false) subq on q.card_nr = subq.card_nr and q.nr = subq.nr
        where is_card = true GROUP BY q.card_nr;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    open cur;
    process_loop: LOOP
        fetch cur into current_card, current_wins;
        if done then
            leave process_loop;
        end if;
        select c.nr_cards into nr_card_var from cards c where c.card_nr = current_card LIMIT 1;
        UPDATE cards c SET c.nr_cards = c.nr_cards + nr_card_var where c.card_nr > current_card and c.card_nr <= current_wins+current_card;
    END LOOP;
    close cur;
END;
call process_pt2();

select sum(nr_cards) from cards;
