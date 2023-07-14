-- combine the HUC8 extents you exported from the HAND FIM4 inundation mapping code
DO $$ 
DECLARE 
    tbl_name text;
BEGIN 
    -- Create new table with the raster column only
    EXECUTE 'CREATE TABLE combined_handmap (rast raster)';

    FOR tbl_name IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
            AND table_type = 'BASE TABLE' 
            AND table_name LIKE 'hand_extent%' 
    LOOP
        EXECUTE format(
            'INSERT INTO combined_handmap SELECT ST_SetSRID(ST_Reclass(rast, 1, ''[-infinity-1):0, [1-infinity):1'', ''8BUI'', 0), 4326) FROM %I', 
            tbl_name
        );
    END LOOP;
END $$;
