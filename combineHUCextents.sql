-- script that combines all the HAND extents you've imported
DO $$ 
DECLARE 
    tbl_name text;
BEGIN 
    -- Create new table with the raster column only
    EXECUTE 'CREATE TABLE combined_handmap (rast raster)';

    FOR tbl_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'  -- replace <username> with your actual username
            AND table_type = 'BASE TABLE' 
            AND table_name LIKE 'hand_extent%' 
    LOOP
        EXECUTE format(
            'INSERT INTO combined_handmap SELECT ST_Reclass(rast, 1, ''[-infinity-1):0, [1-infinity):1'', ''8BUI'', 0) FROM %I', 
            tbl_name
        );
    END LOOP;
END $$;