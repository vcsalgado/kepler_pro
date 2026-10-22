CREATE OR REPLACE FUNCTION keplersc.jmm_creating_inserts_for_ifz_bp_to_upd_tbls_ty(p_type text, p_suc integer)
 RETURNS TABLE(insert_line text)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de uso general
	flag int;
	i int;
	var_type text; 
	var_id_cat int;
	var_insert text;
	rec1 record;
	psuc int;

begin
	
	flag = 0;

	var_type = upper(p_type);

	psuc = p_suc;
	
	drop table if exists tmpTbl;
	create temp table tmpTbl (
		c1 text
	);


	if var_type = 'BP' then
	
		flag = flag + 1;
	
		insert into tmpTbl 
		SELECT r.* FROM (

		-- CAT 1001 : 
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1001::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdrecep where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1001 and v.id_suc = psuc
		) and  length(c1) > 0 
		and upper(c11) = 'S' /*Activo*/
		
		
		union all 
		
		-- CAT 1004 : 
		-- MAKE QRY
		
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1004::text || E'\'' || ',' || E'\'' || q.cilindros || E'\'' || ',' || E'\'' || q.cilindros || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from (
		select distinct(c50) cilindros from keplersc.kdiv where c50::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1004  and v.id_suc = psuc
		) 
		) q
		
		
		union all
		
		-- CAT 1005 : 
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1005::text || E'\'' || ',' || E'\'' || upper(left(i.color,3)) || E'\'' || ',' || E'\'' || i.color || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from (
		
		select r.* from ( select q.color, count(q.vin) vins_count from (
			select  
				upper( split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','')
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1) ) as color, c4 vin 
			from keplersc.kdserie 
			where length(trim(
				upper(split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','') 
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1))
			)) > 3 
		) q group by q.color ) r where r.vins_count > 100 /*70*/ and r.color not in ('BLACK','BLUE','WHITE','SILVER','NEGRA','BLANCA','ROJA','CHAMPAA') -- 20 rows 
			-- DIFF : To get crossing 
			and r.color not in (
				select /*v.id_cat, c.cve_cat, v.cve_val,*/ v.dscr_val from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1005 and v.id_suc = psuc
			) -- 7 rows
		
		-- For Inserts 
		) i
		
		union all
		
		-- CAT 1007 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1007::text || E'\'' || ',' || E'\'' || left(q.combustible,3) || E'\'' || ',' || E'\'' || q.combustible || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from (
		select distinct(trim(c53)) combustible from keplersc.kdiv where length(trim(c53)) > 0 and c53 not in (
			select v.dscr_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1007 and v.id_suc = psuc
		) 
		) q
		
		union all
		
		-- CAT 1010 :  
		/*
		-- Harmonized 
		select * from keplersc.ifz_bp_citas_estatus -- 8 rows
		*/
		
		-- CAT 1011 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1011::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdcatestatusorden where c1::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1011 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1014 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1014::text || E'\'' || ',' || E'\'' || c1 || '-' || c2 || E'\'' || ',' || E'\'' || c3 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdmodelos where c1 || '-' || c2 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1014 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1015 :
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1015::text || E'\'' || ',' || E'\'' || c1::int::text || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdf3fp where c1::int::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1015 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1019 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1019::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c3 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdoper where c12 = 'S' and c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1019 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1022 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1022::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c3 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdmargen where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1022 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1023 :  
		-- JM2 Alternative Query
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1023::text || E'\'' || ',' || E'\'' || upper(left(i.color,3)) || E'\'' || ',' || E'\'' || i.color || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from (
		
		select r.* from ( select q.color, count(q.vin) vins_count from (
			select  
				upper( split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','')
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1) ) as color, c4 vin 
			from keplersc.kdserie 
			where length(trim(
				upper(split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','') 
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1))
			)) > 3 
		) q group by q.color ) r where r.vins_count > 100 /*70*/ and r.color not in ('BLACK','BLUE','WHITE','SILVER','NEGRA','BLANCA','ROJA','CHAMPAA') -- 20 rows 
			-- DIFF : To get crossing 
			and r.color not in (
				select /*v.id_cat, c.cve_cat, v.cve_val,*/ v.dscr_val from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1023 and v.id_suc = psuc
			) -- 13 rows 
		
		-- For Inserts 
		) i
		
		union all
		
		-- CAT 1024 :  
		-- JM2 Alternative Query
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1024::text || E'\'' || ',' || E'\'' || upper(left(i.color,3)) || E'\'' || ',' || E'\'' || i.color || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from (
		
		select r.* from ( select q.color, count(q.dscr_color) regs_count from (
			select 
				-- /*distinct(c3),*/ distinct(c4)   
				upper( split_part(
							replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
							replace(replace(replace(replace(replace(replace(replace(replace(c4,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','')
							,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
						,' ',1) ) as color, c4 dscr_color 
			from keplersc.kdice3
			where length(trim(
					upper(split_part(
						replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
						replace(replace(replace(replace(replace(replace(replace(replace(c4,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','') 
						,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
					,' ',1))
				)) > 3 
		) q group by q.color ) r where r.regs_count > 30 /*100*/ /*70*/ and r.color not in ('TELA','PIEL') -- 2 rows 
			-- DIFF : To get crossing 
			and r.color not in (
				select /*v.id_cat, c.cve_cat, v.cve_val,*/ v.dscr_val from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1024 and v.id_suc = psuc
			) -- 13 rows 
		
		-- For Inserts 
		) i
		
		union all
		
		-- CAT 1025 :  
		-- MAKE QRY		
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1025::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdmarcas where length(trim(c2)) > 0 and c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1025 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1026 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1026::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdf3pais where length(trim(c2)) > 0 and c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1026 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1031 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1031::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdmargen where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1031 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1032 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1032::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdicatprecio where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1032 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1037 :  
		-- MAKE QRY
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1037::text || E'\'' || ',' || E'\'' || door || E'\'' || ',' || E'\'' || door || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from ( select distinct(c54) as door from keplersc.kdiv where c54 >= 2 ) r where r.door::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1037 and v.id_suc = psuc
		) 
		
		union all
		
		-- Commented 20250426 ... applied 1 time only 
		/*
		-- CAT 1043 :  
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1043::text || E'\'' || ',' || E'\'' || 'BPR' || E'\'' || ',' || E'\'' || 'Business Pro' || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.ifz_bp_cats_values_ty where id_cat = 1043 and cve_val not in ('K80')
		
		union all
		*/
		
		-- CAT 1048 :  
		-- MAKE QRY		
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1048::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.catpuntos where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1048 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1051 :  
		-- MAKE QRY		
		select 'Insert Into CatalogoElemento Values (' || E'\'' || 1051::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
		as insert_str
		from keplersc.kdtoper where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1051 and v.id_suc = psuc
		)
		
				
		) r -- MAIN SELECT 
		;
		
		/*
	    for var_id_cat in select id_cat from keplersc.ifz_bp_cats order by id_cat 
		loop
	
			--insert into tmpTbl values(var_id_cat::text);
			
			for rec1 in select * from keplersc.ifz_bp_cats_values_ty where id_cat = var_id_cat order by cve_val 
			loop
		
				select 'Insert Into CatalogoElemento Values (' || E'\'' || v.id_cat::text || E'\'' || ',' || E'\'' || v.cve_val || E'\'' || ',' || E'\'' || v.dscr_val || E'\'' || ',' || psuc::text || ',' || E'\'' || '1' || E'\'' || ',Getdate(),0,' || E'\'' || E'\'' || ',1)' 
				into var_insert 
				from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = var_id_cat and v.cve_val = rec1.cve_val; 
			
				insert into tmpTbl values(var_insert);
			
			end loop;
				
		end loop;
		*/
	
		return query select * from tmpTbl;
	
	end if;

	if var_type = 'GM-W' then
	
		flag = flag + 1;
	
		delete from keplersc.ifz_bp_cats_values_swap_ty;
		
		insert into tmpTbl 
		SELECT r.* FROM (

		-- CAT 1001 : 
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1001::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdrecep where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1001 and v.id_suc = psuc 
				and id_suc = psuc
		) and  length(c1) > 0 
		and upper(c11) = 'S' /*Activo*/
		
		union all 
		
		-- CAT 1004 : 
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1004::text || E'\'' || ',' || E'\'' || q.cilindros || E'\'' || ',' || E'\'' || q.cilindros || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from (
		select distinct(c50) cilindros from keplersc.kdiv where c50::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1004 and v.id_suc = psuc
		) 
		) q
		
		union all
		
		-- CAT 1005 : 
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1005::text || E'\'' || ',' || E'\'' || upper(left(i.color,3)) || E'\'' || ',' || E'\'' || i.color || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from (
		
		select r.* from ( select q.color, count(q.vin) vins_count from (
			select  
				upper( split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','')
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1) ) as color, c4 vin 
			from keplersc.kdserie 
			where length(trim(
				upper(split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','') 
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1))
			)) > 3 
		) q group by q.color ) r where r.vins_count > 100 /*70*/ and r.color not in ('BLACK','BLUE','WHITE','SILVER','NEGRA','BLANCA','ROJA','CHAMPAA') -- 20 rows 
			-- DIFF : To get crossing 
			and r.color not in (
				select /*v.id_cat, c.cve_cat, v.cve_val,*/ v.dscr_val from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1005 and v.id_suc = psuc
			) -- 7 rows
		
		-- For Inserts 
		) i
		
		union all	
		
		-- CAT 1007 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1007::text || E'\'' || ',' || E'\'' || left(q.combustible,3) || E'\'' || ',' || E'\'' || q.combustible || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from (
		select distinct(trim(c53)) combustible from keplersc.kdiv where length(trim(c53)) > 0 and c53 not in (
			select v.dscr_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1007 and v.id_suc = psuc
		) 
		) q
		
		union all
		
		-- CAT 1010 :  
		/*
		-- Harmonized 
		select * from keplersc.ifz_bp_citas_estatus -- 8 rows
		*/
		
		-- CAT 1011 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1011::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdcatestatusorden where c1::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1011 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1014 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1014::text || E'\'' || ',' || E'\'' || c1 || '-' || c2 || E'\'' || ',' || E'\'' || c3 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdmodelos where c1 || '-' || c2 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1014 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1015 :
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1015::text || E'\'' || ',' || E'\'' || c1::int::text || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdf3fp where c1::int::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1015 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1019 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1019::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c3 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdoper where c12 = 'S' and c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1019 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1022 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1022::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c3 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdmargen where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1022 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1023 :  
		-- JM2 Alternative Query
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1023::text || E'\'' || ',' || E'\'' || upper(left(i.color,3)) || E'\'' || ',' || E'\'' || i.color || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from (
		
		select r.* from ( select q.color, count(q.vin) vins_count from (
			select  
				upper( split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','')
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1) ) as color, c4 vin 
			from keplersc.kdserie 
			where length(trim(
				upper(split_part(
					replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
					replace(replace(replace(replace(replace(replace(replace(replace(c10,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','') 
					,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
				,' ',1))
			)) > 3 
		) q group by q.color ) r where r.vins_count > 100 /*70*/ and r.color not in ('BLACK','BLUE','WHITE','SILVER','NEGRA','BLANCA','ROJA','CHAMPAA') -- 20 rows 
			-- DIFF : To get crossing 
			and r.color not in (
				select /*v.id_cat, c.cve_cat, v.cve_val,*/ v.dscr_val from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1023 and v.id_suc = psuc
			) -- 13 rows 
		
		-- For Inserts 
		) i
		
		union all
		
		-- CAT 1024 :  
		-- JM2 Alternative Query
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1024::text || E'\'' || ',' || E'\'' || upper(left(i.color,3)) || E'\'' || ',' || E'\'' || i.color || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from (
		
		select r.* from ( select q.color, count(q.dscr_color) regs_count from (
			select 
				-- /*distinct(c3),*/ distinct(c4)   
				upper( split_part(
							replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
							replace(replace(replace(replace(replace(replace(replace(replace(c4,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','')
							,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
						,' ',1) ) as color, c4 dscr_color 
			from keplersc.kdice3
			where length(trim(
					upper(split_part(
						replace(replace(replace(replace(replace(replace(replace(replace(replace(replace( 
						replace(replace(replace(replace(replace(replace(replace(replace(c4,'-',' '),'_',' '),'/',' '),'.',''),'+',''),'?',''),'X',''),'}','') 
						,'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0','')
					,' ',1))
				)) > 3 
		) q group by q.color ) r where r.regs_count > 30 /*100*/ /*70*/ and r.color not in ('TELA','PIEL') -- 2 rows 
			-- DIFF : To get crossing 
			and r.color not in (
				select /*v.id_cat, c.cve_cat, v.cve_val,*/ v.dscr_val from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1024 and v.id_suc = psuc
			) -- 13 rows 
		
		-- For Inserts 
		) i
		
		union all
		
		-- CAT 1025 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1025::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdmarcas where length(trim(c2)) > 0 and c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1025 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1026 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1026::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdf3pais where length(trim(c2)) > 0 and c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1026 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1031 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1031::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdmargen where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1031 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1032 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1032::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdicatprecio where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1032 and v.id_suc = psuc
		)
		
		union all
		
		-- CAT 1037 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1037::text || E'\'' || ',' || E'\'' || door || E'\'' || ',' || E'\'' || door || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from ( select distinct(c54) as door from keplersc.kdiv where c54 >= 2 ) r where r.door::text not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1037 and v.id_suc = psuc 
		) 
		
		union all
		
		-- Commented 20250426 ... applied 1 time only
		/*
		-- CAT 1043 :  
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1043::text || E'\'' || ',' || E'\'' || 'BPR' || E'\'' || ',' || E'\'' || 'Business Pro' || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.ifz_bp_cats_values_ty where id_cat = 1043 and cve_val not in ('K80')
		
		union all
		*/
		
		-- CAT 1048 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1048::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.catpuntos where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1048 and v.id_suc = psuc 
		)
		
		union all
		
		-- CAT 1051 :  
		-- MAKE QRY
		select 'Insert Into keplersc.ifz_bp_cats_values_swap_ty Values (' || E'\'' || 1051::text || E'\'' || ',' || E'\'' || c1 || E'\'' || ',' || E'\'' || c2 || E'\'' || ',' || E'\'' || psuc::text || E'\'' || ');' 
		as insert_str
		from keplersc.kdtoper where c1 not in (
			select v.cve_val /*v.id_cat, c.cve_cat, v.cve_val, v.dscr_val*/ from keplersc.ifz_bp_cats_values_ty v inner join keplersc.ifz_bp_cats c on v.id_cat = c.id_cat where c.id_cat = 1051 and v.id_suc = psuc 
		)
		

		) r -- MAIN SELECT 
		;
		
		--return query select * from tmpTbl;
		
		for rec1 in select * from tmpTbl  
		loop
	
			var_insert = rec1.c1;
			
			execute var_insert;
		
		end loop;

		return query select (id_cat::text || ' | ' || cve_val || ' | ' || dscr_val || ' | ' || id_suc::text) from keplersc.ifz_bp_cats_values_swap_ty;
	
	end if;

	if var_type = 'GM-D' then
	
		flag = flag + 1;
		i = 0;
	
		for rec1 in select * from keplersc.ifz_bp_cats_values_swap_ty  
		loop
			
			i = i + 1;
		
			insert into keplersc.ifz_bp_cats_values_ty values(rec1.id_cat, rec1.cve_val, rec1.dscr_val, rec1.id_suc);
		
		end loop;
		
		return query select i::text || ' Rows.{Data} were Inserted on TBL.{ifz_bp_cats_values} ...';
	
	end if;

	if flag = 0 then
		return query select 'Option Unavailable ...';
	end if;

exception
	when others then
		return query select /*'jmm_test_dinamic', '_tbl',*/ sqlerrm /*, sqlstate*/;
	
end;
$function$
