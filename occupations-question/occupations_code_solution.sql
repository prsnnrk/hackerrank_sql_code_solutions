SET NULL "NULL";
SET FEEDBACK OFF;
SET ECHO OFF;
SET HEADING OFF;
SET WRAP OFF;
SET LINESIZE 10000;
SET TAB OFF;
SET PAGES 0;
SET DEFINE OFF;

/*
Enter your query here.
Please append a semicolon ";" at the end of the query and enter your query in a single line to avoid error.
*/
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE copy_cursor_data AS
    
    -- 1. Declare the first cursor
    CURSOR c_names IS 
        SELECT name, occupation
        FROM occupations
        ORDER BY CASE WHEN occupation = 'Doctor' THEN 1
              WHEN occupation = 'Professor' THEN 2
              WHEN occupation = 'Singer' THEN 3
              WHEN occupation = 'Actor' THEN 4
        END NULLS LAST;
     
     CURSOR c_doctor_names IS 
        SELECT name, occupation
        FROM occupations
        WHERE occupation = 'Doctor'
        ORDER BY name
        NULLS LAST;   
        
     CURSOR c_professor_names IS 
        SELECT name, occupation
        FROM occupations
        WHERE occupation = 'Professor'
        ORDER BY name
        NULLS LAST;
        
     CURSOR c_singer_names IS 
        SELECT name, occupation
        FROM occupations
        WHERE occupation = 'Singer'
        ORDER BY name
        NULLS LAST;
    
     CURSOR c_actor_names IS 
        SELECT name, occupation
        FROM occupations
        WHERE occupation = 'Actor'
        ORDER BY name
        NULLS LAST;
        
    -- Define the specific width (index spacing) for each column
    v_col1_w CONSTANT NUMBER := 15;
    v_col2_w CONSTANT NUMBER := 15;
    v_col3_w CONSTANT NUMBER := 15;
    v_col4_w CONSTANT NUMBER := 15;
    v_max_count NUMBER := 0;
    TYPE str_arr_name_col IS VARRAY(20) OF VARCHAR2(50);
     
    -- initialize string arrays:
    v_doc_null str_arr_name_col := str_arr_name_col();
    v_prof_null str_arr_name_col := str_arr_name_col();
    v_sing_null str_arr_name_col := str_arr_name_col();
    v_act_null str_arr_name_col := str_arr_name_col();
    
    -- 2. Define a nested table type matching the cursor row structure
    TYPE t_names_list IS TABLE OF c_names%ROWTYPE;
    v_names t_names_list;
    
    TYPE t_doctor_names IS TABLE OF c_names%ROWTYPE;
    v_doctor_names t_doctor_names;
    
    TYPE t_professor_names IS TABLE OF c_names%ROWTYPE;
    v_professor_names t_professor_names;
    
    TYPE t_singer_names IS TABLE OF c_names%ROWTYPE;
    v_singer_names t_singer_names;
    
    TYPE t_actor_names IS TABLE OF c_names%ROWTYPE;
    v_actor_names t_actor_names;
BEGIN
    -- DBMS_OUTPUT.PUT_LINE('Hello World!');
    -- 3. Open source cursor and fetch data into the collection
    OPEN c_names;
    FETCH c_names BULK COLLECT INTO v_names;
    CLOSE c_names;
    
    OPEN c_doctor_names;
    FETCH c_doctor_names BULK COLLECT INTO v_doctor_names;  
    CLOSE c_doctor_names;

    OPEN c_professor_names;
    FETCH c_professor_names BULK COLLECT INTO v_professor_names;  
    CLOSE c_professor_names;
    
    OPEN c_singer_names;
    FETCH c_singer_names BULK COLLECT INTO v_singer_names;  
    CLOSE c_singer_names;
    
    OPEN c_actor_names;
    FETCH c_actor_names BULK COLLECT INTO v_actor_names;  
    CLOSE c_actor_names;
    
    
    SELECT count
    INTO v_max_count
    FROM (
        SELECT occupation, COUNT(*) AS count
        FROM occupations
        GROUP BY occupation
        ORDER BY COUNT(*) DESC 
    )
    WHERE ROWNUM = 1;
    
    -- TESTING:
    -- DBMS_OUTPUT.PUT_LINE(v_max_count);
    
    FOR y IN 1 .. v_max_count LOOP
            IF y <= (v_doctor_names.COUNT) THEN
                v_doc_null.EXTEND;
                v_doc_null(v_doc_null.LAST) := v_doctor_names(y).name;
            ELSE
                v_doc_null.EXTEND;
                v_doc_null(v_doc_null.LAST) := 'NULL';
            END IF;    
            
            IF y <= (v_professor_names.COUNT) THEN
                v_prof_null.EXTEND;
                v_prof_null(v_doc_null.LAST) := v_professor_names(y).name;
            ELSE
                v_prof_null.EXTEND;
                v_prof_null(v_prof_null.LAST) := 'NULL';
            END IF;     
            
            IF y <= (v_singer_names.COUNT) THEN
                v_sing_null.EXTEND;
                v_sing_null(v_sing_null.LAST) := v_singer_names(y).name;
            ELSE
                v_sing_null.EXTEND;
                v_sing_null(v_sing_null.LAST) := 'NULL';
            END IF;     
            
            IF y <= (v_actor_names.COUNT) THEN
                v_act_null.EXTEND;
                v_act_null(v_act_null.LAST) := v_actor_names(y).name;
            ELSE
                v_act_null.EXTEND;
                v_act_null(v_act_null.LAST) := 'NULL';
            END IF; 
    END LOOP;   
    
    FOR p IN 1 .. v_max_count LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_doc_null(p), v_col1_w) || RPAD(v_prof_null(p), v_col2_w) || RPAD(v_sing_null(p), v_col3_w) || RPAD(v_act_null(p), v_col4_w)
        );
    END LOOP;
END copy_cursor_data;
/

EXECUTE copy_cursor_data;

exit;
