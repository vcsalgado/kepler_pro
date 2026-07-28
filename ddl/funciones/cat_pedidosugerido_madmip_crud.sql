CREATE OR REPLACE FUNCTION keplersc.cat_pedidosugerido_madmip_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Cursores
--Autor: Saltiel Rc
--Fecha: 10/03/2022
--Bitácora de cambios
--Fixed.1 by:JMM , 21/08/2023 
declare
v_sucursal_id text= ''; 
v_C1 text = '';

--/*
v_c26 numeric = 0;
v_c27 numeric = 0;
v_c28 numeric = 0;
v_c29 numeric = 0;
v_c30 numeric = 0;
--*/

-- Fixed by JMM , 20230824
/*
v_c26 decimal = 0.00;
v_c27 decimal = 0.00;
v_c28 decimal = 0.00;
v_c29 decimal = 0.00;
v_c30 decimal = 0.00;
*/
/*
v_c26 int = 0;
v_c27 int = 0;
v_c28 int = 0;
v_c29 int = 0;
v_c30 int = 0;
*/
-- End Fixed by JMM 

v_contador numeric = 0;

resultado text= '';
mensaje text = '0';
adicionales text = '';
totreg int = 0;
strtTexto text ='';
v_nocatalogo text =''; 

n1_anio numeric = 0 ; --anio
r1_anio text  = '' ; --anio string
n2_mes numeric = 0;
n3 numeric = 0;
n4 numeric = 0;
contador numeric = 0;

--/*
n11 numeric = 0;
n12 numeric = 0;
n13 numeric = 0;
n14 numeric = 0;
n15 numeric = 0;
n16 numeric = 0;
--*/

-- Fixed by JMM , 20230821
/*
n11 decimal = 0.00;
n12 decimal = 0.00;
n13 decimal = 0.00;
n14 decimal = 0.00;
n15 decimal = 0.00;
n16 decimal = 0.00;
*/
/*
n11 int = 0;
n12 int = 0;
n13 int = 0;
n14 int = 0;
n15 int = 0;
n16 int = 0;
*/
-- End Fixed by JMM 

r2 text = '';

--/*
b1 numeric = 0;
b2 numeric = 0;
b3 numeric = 0;
b4 numeric = 0;
b5 numeric = 0;
b6 numeric = 0;
b7 numeric = 0;
b8 numeric = 0;
--*/

-- Fixed by JMM , 20230824
/*
b1 decimal = 0.00;
b2 decimal = 0.00;
b3 decimal = 0.00;
b4 decimal = 0.00;
b5 decimal = 0.00;
b6 decimal = 0.00;
b7 decimal = 0.00;
b8 decimal = 0.00;
*/
/*
b1 int = 0;
b2 int = 0;
b3 int = 0;
b4 int = 0;
b5 int = 0;
b6 int = 0;
b7 int = 0;
b8 int = 0;
*/
-- End Fixed by JMM

BEGIN
	v_sucursal_id := upper((xpath('//document/k_sucn/text()', dataxml))[1]::text); --C1
	--LISTADO_P 
	--borrar tablas 	
	delete from keplersc.KDINP where c1 = v_sucursal_id ;
	delete from keplersc.KDINPDET where c1 = v_sucursal_id ;
	--raise notice 'Ini %' , (select clock_timestamp());
	n1_anio = (select extract(year from  current_timestamp));
	n2_mes  = (select extract(month from current_timestamp)-6);
	
	if n2_mes <= 0 then 
		n2_mes = n2_mes + 12;
		n1_anio = n1_anio - 1;
	end if;
	
	r1_anio = n1_anio ::text ;
	--v_sucursal_id  ,v_C1, r1_anio 
	
	-- Saltiel
    /*
	for v_C1,v_c26,v_c27,v_c28,v_c29,v_c30 in select c1,c26,c27,c28,c29,c30  from  keplersc.KDINI where C32 = ''  or (C32 <> '' and C3 = 'N')  
		loop      --loop 1 raise notice 'Registro %' , v_C1;
			
	*/		
	-- Fix JMM
	for v_C1,v_c26,v_c27,v_c28,v_c29,v_c30 in 
		select i.c1, i.c26, i.c27, i.c28, i.c29, i.c30  from  keplersc.KDINI i 
		left join keplersc.kding g on g.c1 = i.c32
		where /*C32 = ''  or (C32 <> '' and C3 = 'N')*/
			( g.c1 isnull or ( g.c1 is not null and g.c3 = 'N' ) ) 		
	loop      --loop 1 raise notice 'Registro %' , v_C1;	
 
		 	--raise notice '%',v_C1 ;
		 	contador = 0;
		 	n11= 0; n12= 0; n13= 0; n14= 0; n15= 0; n16= 0;
			case n2_mes
				when 1 then
				select c40,c41,c42,c43,c44,c45 into n11,n12,n13,n14,n15,n16  from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1::text and c3 = r1_anio;
				when 2 then
				select c41,c42,c43,c44,c45,c46 into n11,n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				when 3 then
				select c42,c43,c44,c45,c46,c47 into n11,n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				when 4 then
				select c43,c44,c45,c46,c47,c48 into n11,n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				when 5 then
				select c44,c45,c46,c47,c48,c49 into n11,n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				when 6 then
				select c45,c46,c47,c48,c49,c50 into n11,n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				when 7 then
				select c46,c47,c48,c49,c50,c51 into n11,n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				when 8 then
				--8
				select c47,c48,c49,c50,c51 into n11,n12,n13,n14,n15 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				select c40 into n16 from keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = (n1_anio + 1)::text ;
				when 9 then
				--9				
				select c48,c49,c50,c51 into n11,n12,n13,n14 from  keplersc.kdink where c1=v_sucursal_id and c2=(v_C1::text) and c3 = r1_anio;						
				select c40,c41 into n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=(v_C1::text) and c3 = (n1_anio+1)::text ;
				if not found then 
						n15 := 0;
						n16 := 0;
				end if;
				when 10 then
				--10
				select c49,c50,c51 into n11,n12,n13  from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				select c40,c41,c42 into n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = (n1_anio+1)::text ;
				when 11 then
				--11
				select c50,c51 into n11,n12 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				select c40,c41,c42,c43  into n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = (n1_anio+1)::text ;
				when 12 then
				--12
				select c51 into n11 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = r1_anio;
				select c40,c41,c42,c43,c43 into n12,n13,n14,n15,n16 from  keplersc.kdink where c1=v_sucursal_id and c2=v_C1 and c3 = (n1_anio+1)::text ;
				end case ;
--			raise notice '1a';
			if (n11 is not null and n12 is not null and n13 is not null and n14 is not null and n15 is not null and n16 is not null) then 
			
				insert into keplersc.KDINPDET (c1,c2,c3,c4,c5,c6,c7,c8) 
				values (v_sucursal_id,v_C1,n11,n12,n13,n14,n15,n16);
				--raise notice 'Insertado : %', v_C1;	 			
				
			end if;
		
			-- Added Fixing JMM (Homologar Calculos con K75)
		
			n11 := 0; n12 := 0; n13:= 0; n14 := 0; n15 := 0; n16 := 0;
		
			select c3,c4,c5,c6,c7,c8 into n11,n12,n13,n14,n15,n16 from keplersc.kdinpdet 
			where c1 = v_sucursal_id and c2 = v_C1;
		
			n11 := coalesce(n11,0); n12 := coalesce(n12,0); n13 := coalesce(n13,0);
			n14 := coalesce(n14,0); n15 := coalesce(n15,0); n16 := coalesce(n16,0);
		
			-- Added Fixing JMM (K75 si las Inicializa, en K80 Faltaba)
		
		
			--seccion dos, 
			contador = 0;
			n3 = 0;
			if(n11 > 0 ) then 
	 			contador = contador + 1;	 			
	 			if (n11 > n3 ) then 
		 			n3 := n11;
	 			end if;
			end if;
			if(n12 > 0 ) then 
	 			contador = contador + 1;
		 		if (n12 > n3 ) then 
		 			n3 := n12;
	 			end if;
			end if;
			if(n13 > 0 ) then 
	 			contador = contador + 1;
		 		if (n13 > n3 ) then 
		 			n3 := n13;
	 			end if;
			end if;
			if(n14 > 0 ) then 
	 			contador = contador + 1;
		 		if (n14 > n3 ) then 
		 			n3 := n14;
	 			end if;
			end if;
			if(n15 > 0 ) then 
	 			contador = contador + 1;
		 		if (n15 > n3 ) then 
		 			n3 := n15;
	 			end if;
			end if;
			if(n16 > 0 ) then 
	 			contador = contador + 1;
		 		if (n16 > n3 ) then 
		 			n3 := n16;
	 			end if;
			end if;

		
			-- Added Fixing JMM (K75 si las Inicializa, en K80 Faltaba)
			--/*
			b1 := 0;  b2 := 0;  b3 := 0;  b4 := 0;  b5 := 0;
			b6 := 0;  b7 := 0;  b8 := 0;
			--*/	
			-- End Added 
		
		
			n4 = n16; 
			if(contador >= 3) then 
				r2 := 'I';
				b1 := ((n11 + n12 + n13 + n14 + n15 + n16) /  6);			 	
				b6 := (((n3 * (v_c29 / 100))-b1)/25);
				b7 := (( v_c28-1 ) / 25);
				b8 := b6 + b7;
				b2 := ((b1 * (v_c26 + v_c27 + v_c30)) / 25);
			    b2 := ceiling(b2);
				--b2 := ceil(b2);
			   	b3 := n3;
  			    b4 := N4;
  			    b5 := b1;
			else
				r2 := 'O';
			end if;
		
	    insert into keplersc.kdinp (c1,c2,c3,c4,c5,c6,c7,c8) 
	    values(v_sucursal_id,v_C1,r2,b1,b2,b3,b4,b5);
		--raise notice 'fin reg %',v_C1 ;
		end loop; --end loop 1 
		update keplersc.KDPEDIDOSUGERIDOCONF 
		set c6 =0,
			c7 = (select now())  
		WHERE c1 = v_sucursal_id ;
	--end for 
		resultado ='1';
		mensaje ='Finalizado';
		adicionales ='';
	--raise notice 'Fin %' , (select clock_timestamp());

return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;	
		mensaje := 'cat_Cursores_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;
END;
$function$
