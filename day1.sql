SELECT SUM(
         CONCAT(
                 REGEXP_REPLACE(data, '^[^0-9]*([0-9]{1}).*$', '$1'),
                 REGEXP_REPLACE(data, '^.*([0-9]{1})[^0-9]*$', '$1')  )) as answer from day_01;

select SUM(CONCAT(
        case
         when locate('one', data)!= 0 and locate('one',data) < REGEXP_INSTR(data, '([0-9]|two|three|four|five|six|seven|eight|nine)') then 1
         when locate('two', data) != 0 and locate('two',data) < REGEXP_INSTR(data, '([0-9]|one|three|four|five|six|seven|eight|nine)') then 2
         when locate('three', data) != 0 and locate('three',data) < REGEXP_INSTR(data, '([0-9]|one|two|four|five|six|seven|eight|nine)') then 3
         when locate('four', data) != 0 and locate('four',data) < REGEXP_INSTR(data, '([0-9]|one|two|three|five|six|seven|eight|nine)') then 4
         when locate('five', data) != 0 and locate('five',data) < REGEXP_INSTR(data, '([0-9]|one|two|three|four|six|seven|eight|nine)') then 5
         when locate('six', data) != 0 and locate('six',data) < REGEXP_INSTR(data, '([0-9]|one|two|three|four|five|seven|eight|nine)') then 6
         when locate('seven', data) != 0 and locate('seven',data) < REGEXP_INSTR(data, '([0-9]|one|two|three|four|five|six|eight|nine)') then 7
         when locate('eight', data) != 0 and locate('eight',data) < REGEXP_INSTR(data, '([0-9]|one|two|three|four|five|six|seven|nine)') then 8
         when locate('nine', data) != 0 and locate('nine',data) < REGEXP_INSTR(data, '([0-9]|one|two|three|four|five|six|seven|eight)') then 9
        else regexp_replace(data,'^[^0-9]*([0-9]{1}).*$', '$1') end ,
        case
         when locate('eno', REVERSE(data))!= 0 and locate('eno', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|owt|eerht|ruof|evif|xis|neves|thgie|enin)') then 1
            when locate('owt', REVERSE(data))!= 0 and locate('owt', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|eerht|ruof|evif|xis|neves|thgie|enin)') then 2
            when locate('eerht', REVERSE(data))!= 0 and locate('eerht', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|ruof|evif|xis|neves|thgie|enin)') then 3
            when locate('ruof', REVERSE(data))!= 0 and locate('ruof', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|eerht|evif|xis|neves|thgie|enin)') then 4
            when locate('evif', REVERSE(data))!= 0 and locate('evif', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|eerht|ruof|xis|neves|thgie|enin)') then 5
            when locate('xis', REVERSE(data))!= 0 and locate('xis', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|eerht|ruof|evif|neves|thgie|enin)') then 6
            when locate('neves', REVERSE(data))!= 0 and locate('neves', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|eerht|ruof|evif|xis|thgie|enin)') then 7
            when locate('thgie', REVERSE(data))!= 0 and locate('thgie', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|eerht|ruof|evif|xis|neves|enin)') then 8
            when locate('enin', REVERSE(data))!= 0 and locate('enin', REVERSE(data)) < REGEXP_INSTR(REVERSE(data), '([0-9]|eno|owt|eerht|ruof|evif|xis|neves|thgie)') then 9
        else regexp_replace(data,'^.*([0-9]{1})[^0-9]*$', '$1') end
    ))
from day_01;


