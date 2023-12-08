
DROP TABLE if exists sln1;
create table sln1(hand text, bid int);


drop function if exists get_type;
create function get_type(hand text) returns int
DETERMINISTIC
begin
    set hand = sort_string(hand);
    if hand regexp '(E{5}|D{5}|C{5}|B{5}|A{5}|9{5}|8{5}|7{5}|6{5}|5{5}|4{5}|3{5}|2{5})' then
        return 6;
    end if;
    if hand regexp '(E{4}|D{4}|C{4}|B{4}|A{4}|9{4}|8{4}|7{4}|6{4}|5{4}|4{4}|3{4}|2{4})' then
        return 5;
    end if;
    if hand regexp '(E{3}|D{3}|C{3}|B{3}|A{3}|9{3}|8{3}|7{3}|6{3}|5{3}|4{3}|3{3}|2{3})' then
        if regexp_replace(hand,'(E{3}|D{3}|C{3}|B{3}|A{3}|9{3}|8{3}|7{3}|6{3}|5{3}|4{3}|3{3}|2{3})','') regexp
           '(E{2}|D{2}|C{2}|B{2}|A{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2})' then
            return 4;
        end if;
        return 3;
    end if;
    if hand regexp '(E{2}|D{2}|C{2}|B{2}|A{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2})' then
        if regexp_replace(hand,'(E{2}|D{2}|C{2}|B{2}|A{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2})','',1,1) regexp
           '(E{2}|D{2}|C{2}|B{2}|A{2}|9{2}|8{2}|7{2}|6{2}|5{2}|4{2}|3{2}|2{2})' then
            return 2;
        end if;
        return 1;
    end if;
    return 0;

end;

drop function if exists normalize_hand;
create function normalize_hand( hand text) returns text
DETERMINISTIC
begin
    set hand = replace( hand, 'A', 'E');
    set hand = replace( hand, 'K', 'D');
    set hand = replace( hand, 'Q', 'C');
    set hand = replace( hand, 'J', 'B');
    set hand = replace( hand, 'T', 'A');
    return hand;
end;

drop function if exists get_value;
create function get_value(hand text) returns int
DETERMINISTIC
begin
    return CONV(hand,16, 10);
end;

drop function if exists sort_string;
create function sort_string(hand text) returns text
DETERMINISTIC
begin
    DECLARE result text;
    select group_concat( c ORDER BY c desc separator '') into result from (
    VALUES ROW(substring(hand,1,1)),
    ROW(substring(hand,2,1)),
    ROW(substring(hand,3,1)),
    ROW(substring(hand,4,1)),
    ROW(substring(hand,5,1))) as t(c);
    return result;
end;

drop procedure if exists parse_data;
CREATE PROCEDURE parse_data()
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE hand, bid text;
    DECLARE cur CURSOR FOR SELECT data FROM day_07;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO input;
        if done then
            leave read_loop;
        end if;

        set hand = regexp_replace(input, '^([AKQJT0-9]+)\\s+([0-9]+)$', '$1');
        set bid = regexp_replace(input, '^([AKQJT0-9]+)\\s+([0-9]+)$', '$2');

        insert into sln1(hand, bid) VALUES(hand, bid);
    end loop;
    close cur;
end;

CALL parse_data();

DROP TABLE IF EXISTS ans1;
CREATE TABLE ans1(rnk int primary key auto_increment, bid int, type int, value text);

insert into ans1 (bid, type,value)  select bid, get_type(normalize_hand(hand)) as type, (normalize_hand(hand)) as val from sln1 order by type, val ;
select sum(rnk * bid) from ans1;


DROP TABLE if exists sln2;
create table sln2(hand text, bid int);


drop function if exists get_type2;
create function get_type2(hand text) returns int
DETERMINISTIC
begin
    if LOCATE('1',hand) then
        return get_joker_type(hand);
    else
        return get_type(hand);
    end if;

end;

drop function if exists get_joker_type;
create function get_joker_type(hand text) returns int
deterministic
BEGIN

    DECLARE tmp_hand text;
    DECLARE tmp_type int;
    set tmp_hand = REPLACE(hand, '1','');
    set tmp_type = get_type(tmp_hand);
    if length(tmp_hand) = 1 or length(tmp_hand)=0 then
        return 6;
    elseif length(tmp_hand) = 2 and tmp_type = 1 then
        return 6;
    elseif length(tmp_hand) = 2 and tmp_type = 0 then
        return 5;
    elseif length(tmp_hand) = 3  and tmp_type = 3 then
        return 6;
    elseif length(tmp_hand) = 3  and tmp_type = 1 then
        return 5;
    elseif length(tmp_hand) = 3 and tmp_type = 0 then
        return 3;
    elseif length(tmp_hand) = 4 and tmp_type = 5 then
        return 6;
    elseif length(tmp_hand) = 4 and tmp_type = 3 then
        return 5;
    elseif length(tmp_hand) = 4 and tmp_type = 2 then
        return 4;
    elseif length(tmp_hand) = 4 and tmp_type = 1 then
        return 3;
    elseif length(tmp_hand) = 4 and tmp_type = 0 then
        return 1;
    end if;
    return 0;
end;

drop function if exists normalize_hand2;
create function normalize_hand2( hand text) returns text
DETERMINISTIC
begin
    set hand = replace( hand, 'A', 'E');
    set hand = replace( hand, 'K', 'D');
    set hand = replace( hand, 'Q', 'C');
    set hand = replace( hand, 'J', '1');
    set hand = replace( hand, 'T', 'A');
    return hand;
end;

drop procedure if exists parse_data2;
CREATE PROCEDURE parse_data2()
BEGIN
    DECLARE done bool;
    DECLARE input text;
    DECLARE hand, bid text;
    DECLARE cur CURSOR FOR SELECT data FROM day_07;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO input;
        if done then
            leave read_loop;
        end if;

        set hand = regexp_replace(input, '^([AKQJT0-9]+)\\s+([0-9]+)$', '$1');
        set bid = regexp_replace(input, '^([AKQJT0-9]+)\\s+([0-9]+)$', '$2');

        insert into sln2(hand, bid) VALUES(hand, bid);
    end loop;
    close cur;
end;

CALL parse_data2();

DROP TABLE IF EXISTS ans2;
CREATE TABLE ans2(rnk int primary key auto_increment, bid int, type int, value bigint, org text);

insert into ans2 (bid, type, value, org)
    (select bid, get_type2(normalize_hand2(hand)) as type,
            HEX(normalize_hand2(hand)) as val,hand from sln2 order by type, val);

select sum(bid*rnk) from ans2;

