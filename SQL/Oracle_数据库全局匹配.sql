CREATE OR REPLACE PROCEDURE P_all_like_search(p_compare IN VARCHAR2) IS
  p_sql   varchar2(2000);
  p_count number;
 -- p_compare VARCHAR2(100);
BEGIN
/* liuzhuang 20190329 */
-- 全库匹配：每个表每个字段与某字符串是否相似
-- 注意：仅用于数据量比较小的测试库，不要用于生产库以及海量数据的库 
/*

-- 建立匹配临时表(须先建表，再编译匹配过程)
create table ALL_LIKE_TEST
(
  table_name  VARCHAR2(100),
  colume_name VARCHAR2(100),
  compare_string VARCHAR2(100)
);
comment on table ALL_LIKE_TEST
  is '--特征值匹配临时表（检索所有包含某字符串的所有表的所有列）';

*/
  -- 此处填入要匹配的字符串
  --p_compare := '新人业务5天速成资料';

  DELETE FROM all_like_test;
  COMMIT;
  for c in (select *
              from user_tab_columns a
             where (a.data_type like '%VARCHAR%' or a.data_type = 'CLOB')
               and a.table_name in (select table_name
                                      from user_tab_comments
                                     where table_type = 'TABLE')) loop
     BEGIN
      p_count := 0;
      p_sql   := 'select count(1) as p_count  from ' || c.table_name ||
                 ' where  instr(' || c.column_name || ','''||p_compare||''') > 0 ';
       execute immediate p_sql
        into p_count;
      if p_count > 0 then
        insert into all_like_test
        values
          (c.table_name,
           c.column_name,p_compare);
        commit;
       -- dbms_output.put_line('匹配：'||c.table_name||'.'||c.column_name);
      end if;
    exception
      when others then
        rollback;
    end;
  end loop;
end;


-- 全库匹配：每个表每个字段与某字符串是否相似 
 
-- 执行匹配过程 
begin
  p_all_like_search('新人业务5天速成资料');
end;

-- 查询匹配结果 
select a.*,
       'select * from ' || a.table_name || ' where ' || a.colume_name ||
       ' like ''%'||a.compare_string||'%'' ;' as p_sql
  from all_like_test a;

-- 复制 p_sql 列的语句，然后新SQL窗口 执行查询  

-- END
