create table test_table
(
   name varchar(54)
   ,value1 int
   ,value2 int
)
distributed by (name);