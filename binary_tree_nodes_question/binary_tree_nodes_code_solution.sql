SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE node_type AS
    CURSOR c_node_pairs IS
        SELECT N, P
        FROM bst
        ORDER BY N;
    
    TYPE c_nodes_tbl_type IS TABLE OF c_node_pairs%ROWTYPE INDEX BY PLS_INTEGER;
    t_nodes c_nodes_tbl_type;
    result VARCHAR2(20) := '';
    node_row_count NUMBER := 0;
    TYPE str_arr IS VARRAY(20) OF VARCHAR2(50);
    result_str_arr str_arr := str_arr();
    counter NUMBER := 0;
BEGIN
    
    OPEN c_node_pairs;
        FETCH c_node_pairs BULK COLLECT INTO t_nodes;
    CLOSE c_node_pairs;
    
    SELECT COUNT(*)
    INTO node_row_count
    FROM bst;
    
    FOR c_node_pair in c_node_pairs LOOP
        IF c_node_pair.P IS NULL THEN
            result := 'Root';
        ELSE
            result_str_arr := str_arr('no match');
            counter := 0;
            FOR i in 1 .. node_row_count LOOP
                IF c_node_pair.N = t_nodes(i).P THEN
                    result := 'Inner';
                    EXIT;
                ELSIF c_node_pair.N != t_nodes(i).P THEN
                    result_str_arr.EXTEND;
                    result_str_arr(result_str_arr.LAST) := 'no match';
                END IF;
            END LOOP;
            FOR j in 1 .. result_str_arr.COUNT LOOP
                IF result_str_arr(j) = 'no match' THEN
                    counter := counter + 1;
                END IF;
            END LOOP;
            IF counter = node_row_count THEN
                result := 'Leaf';
            END IF;
        END IF;
        DBMS_OUTPUT.PUT_LINE(c_node_pair.N || ' ' || result);
    END LOOP;
    
END node_type;
/

BEGIN
    node_type;
END;
/

exit;
