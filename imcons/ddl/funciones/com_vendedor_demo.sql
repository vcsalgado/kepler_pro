CREATE OR REPLACE FUNCTION keplersc.com_vendedor_demo(dataxml xml)
 RETURNS TABLE(orden integer, variable text, valor1 text, valor2 text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Obtiene el detalle de comisiones para un invetario en particular
	--Autor:Victor Salgado
	--Fecha:24/01/2023
	--Variables de definicion de documento
	sucursal_id text = '';
	inventario text = '';


	--Variables de proceso
	rec_E_INF record;
	rec_F_UV record;
	rec_G_COMISMOV record; --Registro de Comisiones
	rec_H_COMISMOV2 record;
	rec_I_COMISADIS record;
	rec_J_PEDIDO record;
	rec_K_IPVA record;
	rec_S_MS record;
	rec_O_VESQ record;
	rec_P_VESQVEH record;
	rec_Q_PORCENTAJES record;
	rec_T_TIPOCOMIS record;
	rec_U_VOBJLINEA record;
	rec_V_IV record;
	
	b1_importe numeric(12,2) = 0.00;
	b2_iva numeric(12,2) = 0.00;
	b3_isan numeric(12,2) = 0.00;
	b5_precioventa numeric(12,2) = 0.00;
	b6_notadescto numeric(12,2) = 0.00;
	b7_subsidio numeric(12,2) = 0.00;
	b8_bonif numeric(12,2) = 0.00;
	b9_cargocostounidad numeric(12,2) = 0.00;
	b10_costocompra numeric(12,2) = 0.00;
	b11_utilbruta numeric(12,2) = 0.00;
	b12_base numeric(12,2) = 0.00;
	b21_factacces numeric(12,2) = 0.00;
	b22_costoacces numeric(12,2) = 0.00;
	b23_utilacces numeric(12,2) = 0.00;
	b25_gastosadmin numeric(12,2) = 0.00;
	b26_comseguro numeric(12,2) = 0.00;
	b27_extras numeric(12,2) = 0.00;
	b30_comisbase numeric(12,2) = 0.00;
	b31_comisedad numeric(12,2) = 0.00;
	b32_descto numeric(12,2) = 0.00;
	b33_comgastosadmon numeric(12,2) = 0.00;
	b34_comacces numeric(12,2) = 0.00;
	b35_comextras numeric(12,2) = 0.00;
	b36_comcomisem numeric(12,2) = 0.00;
	b37_bonolinea numeric(12,2) = 0.00;
	b38_seguro numeric(12,2) = 0.00;
	b39_comtotal numeric(12,2) = 0.00;
	b50_comisbase numeric(12,2)=0;
	b51_comisedad numeric(12,2)=0;
	b52_notadescto numeric(12,2)=0;
	b53_comgastosadmon numeric(12,2)=0;
	b54_comubacces numeric(12,2)=0;
	b55_comextras numeric(12,2)=0;
	b56_combonosem numeric(12,2)=0;
	b57_combonolinea  numeric(12,2)=0;
	b58_comseguros numeric(12,2)=0;	

	n1_operaciones int =0;
	n2_esquema int = 0;
	n3_semanaent int = 0;
	n4_diasinv int = 0;

	error text = '';
	xmlResultado xml;
	anio text = '';
	mes text = '';
	dia text = '';
	strFecha text = '';
	strVal text = '';
	totReg int = 0;
	diaSemana int = 0;
	diaIni int = 0;
	fechaIni date ;
	fechaFin date ;
	valFecha date;
	intVal int = 0;

begin
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	inventario := (xpath('//document/k_inventario/text()', dataxml))[1];

	select count(*) into totReg from keplersc.kdinf where c1=sucursal_id and c2=inventario;
	if totReg>0 then
		select * into rec_E_INF from keplersc.kdinf where c1=sucursal_id and c2=inventario;
	else
		raise exception 'No se encontró información del inventario(kdinf).';
	end if; 
	select count(*) into totReg from keplersc.kdcomismov where c1=sucursal_id and c8=inventario and c10='0';
	if totReg>0 then
		select * into rec_G_COMISMOV from keplersc.kdcomismov where c1=sucursal_id and c8=inventario and c10='0' order by c6 desc limit 1;
	else
		raise exception 'No se encontró información del inventario(comismov).';
	end if; 
	select count(*) into totReg from keplersc.kdcomismov2 where 
		c1=rec_G_COMISMOV.c1 and c2=rec_G_COMISMOV.c2 and c3=rec_G_COMISMOV.c3 and
		c4=rec_G_COMISMOV.c4 and c5=rec_G_COMISMOV.c5 and c6=rec_G_COMISMOV.c6; 
--		and c7=rec_G_COMISMOV.c7 and c10=rec_G_COMISMOV.c10; 
	if totReg>0 then
		select * into rec_H_COMISMOV2 from keplersc.kdcomismov2 where 
			c1=rec_G_COMISMOV.c1 and c2=rec_G_COMISMOV.c2 and c3=rec_G_COMISMOV.c3 and
			c4=rec_G_COMISMOV.c4 and c5=rec_G_COMISMOV.c5 and c6=rec_G_COMISMOV.c6;
--			and c7=rec_G_COMISMOV.c7 and c10=rec_G_COMISMOV.c10; 
	else
		raise exception 'No se encontró información del inventario(comismov2).';
	end if; 		
	
	select count(*) into totReg from keplersc.kdcomisadis where 
		c1=rec_G_COMISMOV.c1 and c2=rec_G_COMISMOV.c2 and c3=rec_G_COMISMOV.c3 and
		c4=rec_G_COMISMOV.c4 and c5=rec_G_COMISMOV.c5 and c6=rec_G_COMISMOV.c6 and
		c7=rec_G_COMISMOV.c10; 

	if totReg>0 then
		select * into rec_I_COMISADIS from keplersc.kdcomisadis where 
			c1=rec_G_COMISMOV.c1 and c2=rec_G_COMISMOV.c2 and c3=rec_G_COMISMOV.c3 and
			c4=rec_G_COMISMOV.c4 and c5=rec_G_COMISMOV.c5 and c6=rec_G_COMISMOV.c6 and
			c7=rec_G_COMISMOV.c10; 
	else
		raise exception 'No se encontró información del inventario(comisadis).';
	end if;
--raise notice 'rec_G_COMISMOV.c9:%',rec_G_COMISMOV.c9;
	select count(*) into totReg from keplersc.kduv where 
		c1=sucursal_id and c2=rec_G_COMISMOV.c9; 
	if totReg>0 then
		select * into rec_F_UV from keplersc.kduv where 
			c1=sucursal_id and c2=rec_G_COMISMOV.c9;
		rec_F_UV.c8 := coalesce(rec_F_UV.c8,'');
		if rec_F_UV.c8 = '' then
			raise exception 'El asesor % no tiene un esquema registrado.',rec_F_UV.c3;
		end if;
	else
		raise exception 'No se encontró información del vendedor(kduv).';
	end if;

	select count(*) into totReg from keplersc.kdpedido where c1=sucursal_id and c2=inventario;
	if totReg>0 then
		select * into rec_J_PEDIDO from keplersc.kdpedido where c1=sucursal_id and c2=inventario limit 1;
	else
		raise exception 'No se encontró información del inventario(pedido).';
	end if; 
	
	b1_importe:=rec_G_COMISMOV.c22;
	b2_iva:=rec_G_COMISMOV.c21;
	b3_isan:=rec_G_COMISMOV.c20;
	b5_precioventa:=b1_importe - b2_iva - b3_isan;
	b6_notadescto:=rec_G_COMISMOV.c15;
	b7_subsidio:=rec_I_COMISADIS.c8;
	b8_bonif:=rec_I_COMISADIS.c9 - rec_I_COMISADIS.c10;
	b9_cargocostounidad:=rec_I_COMISADIS.c13 - rec_I_COMISADIS.c14;
	b10_costocompra:=rec_G_COMISMOV.c23;
	b11_utilbruta:=b5_precioventa-b6_notadescto-b7_subsidio+
		b8_bonif-b9_cargocostounidad-b10_costocompra;

	for rec_K_IPVA in 
		select * from keplersc.kdipva where c1=sucursal_id and c2=inventario
	loop
		if rec_K_IPVA.c10 = 0 then 
			b21_factacces:=b21_factacces + rec_K_IPVA.c25;
		else
			b21_factacces:=b21_factacces - rec_K_IPVA.c25;		
		end if;
	end loop;
	b22_costoacces:=rec_I_COMISADIS.c11-rec_I_COMISADIS.c12;
	b23_utilacces:=b22_costoacces+b21_factacces;
	b25_gastosadmin:=rec_G_COMISMOV.c16;
	b26_comseguro:=rec_G_COMISMOV.c17;
	b27_extras:=rec_G_COMISMOV.c19;
	n4_diasinv:=date_part('day', rec_G_COMISMOV.c7 - rec_G_COMISMOV.c24);

	--Calcular semana de entrega
	anio:=extract(year from rec_G_COMISMOV.c7)::text; 
	strVal:=extract(month from rec_G_COMISMOV.c7)::text;
	mes:=lpad(strVal::text,2,'0');
	strVal:=extract(day from rec_G_COMISMOV.c7)::text;
	dia:=lpad(strVal::text,2,'0');
	strFecha:=concat(anio,'-',mes,'-','01');
	valFecha:=to_date(strFecha,'yyyy-mm-dd');
	intVal:=extract(week from valFecha);
	n3_semanaent:=intVal;
	intVal:=extract(week from rec_G_COMISMOV.c7);
	
	--Semana de entrega
	n3_semanaent:=intVal-n3_semanaent +1;

	--Calcular fecha inicio
	anio:=extract(year from rec_G_COMISMOV.c7)::text; 
	strVal:=extract(month from rec_G_COMISMOV.c7)::text;
	mes:=lpad(strVal::text,2,'0');
	strVal:=extract(day from rec_G_COMISMOV.c7)::text;
	dia:=lpad(strVal::text,2,'0');
	strFecha:=concat(anio,'-',mes,'-','01');
	fechaIni:=to_date(strFecha,'yyyy-mm-dd');

	--Calcular fecha de corte
	valFecha:=to_date(strFecha,'yyyy-mm-dd');
	valFecha:=valFecha + interval '1 month';
	valFecha:=valFecha - interval '1 day';
	fechaFin:=valFecha;
/*
	diaSemana:=extract(dow from fechaFin);
	diaSemana:=diaSemana+1;
	if diaSemana>3 then
		intVal:=extract(day from fechaFin);
		intVal:=intVal-diaSemana+3;
		strVal:=intVal::text;
		strVal:=lpad(strVal::text,2,'0');
		strFecha:=concat(anio,'-',mes,'-',strVal);
		fechaFin:=to_date(strFecha,'yyyy-mm-dd');
	end if;
*/

	--Operaciones asesor
--raise notice 'FIni:% FFIn:%',fechaIni, fechaFin;
	n1_operaciones:=0;
	select count(*) into totReg from keplersc.kdcomismov where 
		c1=sucursal_id and c9=rec_F_UV.c2 and c7>=fechaIni and c7<=fechaFin
		and c10='0';
	n1_operaciones:=n1_operaciones+totReg;
	select count(*) into totReg from keplersc.kdcomismov where 
		c1=sucursal_id and c9=rec_F_UV.c2 and c7>=fechaIni and c7<=fechaFin
		and c10<>'0';
	n1_operaciones:=n1_operaciones-totReg;

--raise notice 'FechaG:% n3_semanaent:% FechaFin:%',rec_G_COMISMOV.c7,n3_semanaent,fechaFin;
	--Esquema
	n2_esquema:=0;
	select count(*) into totReg from keplersc.kdvesq where c1=rec_F_UV.c8;

	if totReg>0 then

		select * into rec_O_VESQ from keplersc.kdvesq where c1=rec_F_UV.c8;
		
		select count(*) into totReg from keplersc.kdvesqveh where c1=sucursal_id 
			and c2=rec_F_UV.c8 and c3=rec_G_COMISMOV.c11 and c4=rec_G_COMISMOV.c14;
		if totReg>0 then
		
			select * into rec_P_VESQVEH from keplersc.kdvesqveh where c1=sucursal_id 
				and c2=rec_F_UV.c8 and c3=rec_G_COMISMOV.c11 and c4=rec_G_COMISMOV.c14;	
			
			select count(*) into totReg from keplersc.kdtipocomis where c1=rec_P_VESQVEH.c5;
			if totReg>0 then
			
				select * into rec_T_TIPOCOMIS from keplersc.kdtipocomis where c1=rec_P_VESQVEH.c5;

				select count(*) into totReg from keplersc.kdporcentajes where c1=rec_P_VESQVEH.c5
					and c2<=n1_operaciones and c3>=n1_operaciones;
				if totReg > 0 then
				
					select * into rec_Q_PORCENTAJES from keplersc.kdporcentajes where c1=rec_P_VESQVEH.c5
						and c2<=n1_operaciones and c3>=n1_operaciones limit 1;	
					n2_esquema:=1;
				end if;
			end if;
		end if;
	end if;

	if n2_esquema > 0 then
		b50_comisbase:=rec_Q_PORCENTAJES.c4;
		b51_comisedad:=rec_Q_PORCENTAJES.c5;
		if n4_diasinv >= rec_T_TIPOCOMIS.c4 then
			b51_comisedad:=rec_Q_PORCENTAJES.c6;
		end if;
		if n4_diasinv >= rec_T_TIPOCOMIS.c5 then
			b51_comisedad:=rec_Q_PORCENTAJES.c7;
		end if;
		if n4_diasinv >= rec_T_TIPOCOMIS.c6 then
			b51_comisedad:=rec_Q_PORCENTAJES.c8;
		end if;	
		b52_notadescto:=rec_Q_PORCENTAJES.c9;
		b53_comgastosadmon:=rec_Q_PORCENTAJES.c10;
		b54_comubacces:=rec_Q_PORCENTAJES.c12;
		b55_comextras:=rec_Q_PORCENTAJES.c13;
		b58_comseguros:=rec_Q_PORCENTAJES.c11;
	
		if rec_T_TIPOCOMIS.c3=0 then
			b12_base:=b1_importe; --Base de importe
		end if;
		if rec_T_TIPOCOMIS.c3=10 then
			b12_base:=b11_utilbruta; --Base de utilidad
		end if;
		if rec_T_TIPOCOMIS.c3=20 then
			b12_base:=b5_precioventa; --Base de precio
		end if;
		if rec_T_TIPOCOMIS.c3=30 then
			b12_base:=rec_Q_PORCENTAJES.c4; --Cuota fija 
		end if;	
		
		if n3_semanaent=1 then
			b56_combonosem:=rec_O_VESQ.c25;
		end if;
		if n3_semanaent=2 then
			b56_combonosem:=rec_O_VESQ.c26;
		end if;
		if n3_semanaent=3 then
			b56_combonosem:=rec_O_VESQ.c27;
		end if;
		if n3_semanaent=4 then
			b56_combonosem:=rec_O_VESQ.c28;
		end if;
		if n3_semanaent=5 then
			b56_combonosem:=rec_O_VESQ.c28;
		end if;	
	end if;

	if rec_T_TIPOCOMIS.c3=30 then
		b30_comisbase:=b12_base;
		b31_comisedad:=b51_comisedad;
	else
		b30_comisbase:=b12_base*b50_comisbase/100;
		b31_comisedad:=b12_base*b51_comisedad/100;
	end if;

	b32_descto:=b52_notadescto*b6_notadescto/100;
	b33_comgastosadmon:=b53_comgastosadmon*b25_gastosadmin/100; 
	b34_comacces:=b54_comubacces*b23_utilacces/100;
	b35_comextras:=b55_comextras*b27_extras/100;
	b36_comcomisem:=b56_combonosem*b12_base/100;

	--Bono por linea
	b37_bonolinea:=0;

	if n2_esquema > 0 then --Se tiene esquema de comision
		if rec_T_TIPOCOMIS.c3=10 then
			select count(*) into totReg from keplersc.kdiv where c1=rec_G_COMISMOV.c12;
			if totReg>0 then
				select * into rec_V_IV from keplersc.kdiv where c1=rec_G_COMISMOV.c12;
				select count(*) into totReg from keplersc.kdvobjlinea where c1=sucursal_id 
					and c2=rec_F_UV.c8 and c3=anio and c4=mes and c5=rec_V_IV.c7;
				if totReg>0 then
					select * into rec_U_VOBJLINEA from keplersc.kdvobjlinea where c1=sucursal_id 
						and c2=rec_F_UV.c8 and c3=anio and c4=mes and c5=rec_V_IV.c7;				
					b57_combonolinea:=	rec_U_VOBJLINEA.c6;
					b37_bonolinea:=b11_utilbruta*b57_combonolinea/100;
				end if;			
			end if;

			if b37_bonolinea=0 then
				select count(*) into totReg from keplersc.kdvobjlinea where c1=sucursal_id 
					and c2=rec_F_UV.c8 and c3=anio and c4=mes and c5=rec_G_COMISMOV.c12;
				if totReg>0 then
					select * into rec_U_VOBJLINEA from keplersc.kdvobjlinea where c1=sucursal_id 
						and c2=rec_F_UV.c8 and c3=anio and c4=mes and c5=rec_V_IV.c12;				
					b57_combonolinea:=	rec_U_VOBJLINEA.c6;
					b37_bonolinea:=b11_utilbruta*b57_combonolinea/100;
				end if;
			end if;
		
		end if;
	end if;
	
	b38_seguro:=b26_comseguro*b58_comseguros/100;

	b39_comtotal:= b30_comisbase + b31_comisedad +
		b32_descto + b33_comgastosadmon + b34_comacces +
		b35_comextras + b36_comcomisem + b37_bonolinea +
		b38_seguro;
	
	--creacion de tabla temporal para el retorno
	drop table if exists tmpRows;
	create temp table tmpRows (
		orden int, 
		variable text, 
		valor1 text,
		valor2 text		
	);	

	insert into tmpRows (orden,variable,valor1,valor2) values(1,'Inventario:',inventario,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(5,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(10,'Fecha de Entrega:',to_char(rec_G_COMISMOV.c7, 'DD/MM/YYYY'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(15,'Asesor de Ventas:',rec_G_COMISMOV.c9,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(20,'Tipo de Operacion:',rec_G_COMISMOV.c11,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(25,'Modelo del Vehiculo:',rec_G_COMISMOV.c12,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(30,'Año:',rec_E_INF.c15,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(35,'Tipo:',rec_E_INF.c21,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(40,'Fecha de Compra:',to_char(rec_G_COMISMOV.c24, 'DD/MM/YYYY'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(45,'Días en inventario:',n4_diasinv,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(50,'Semana:',n3_semanaent,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(55,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(60,'Inicio de corte:',to_char(fechaIni, 'DD/MM/YYYY'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(65,'Fin de corte:',to_char(fechaFin, 'DD/MM/YYYY'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(70,'Número de Operaciones:',n1_operaciones,'');
	insert into tmpRows (orden,variable,valor1,valor2) values(75,'Importe:',to_char(b1_importe,'fm999999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(80,'IVA:',to_char(b2_iva,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(85,'ISAN:',to_char(b3_isan,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(90,'Subtotal:',to_char(b5_precioventa,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(95,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(100,'Nota de Descuento:',to_char(b6_notadescto,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(105,'Subsidio:',to_char(b7_subsidio,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(100,'Bonificaciones:',to_char(b8_bonif,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(115,'Cargos al Costo:',to_char(b9_cargocostounidad,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(120,'Costo de la unidad:',to_char(b10_costocompra,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(125,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(130,'Utilidad Bruta:',to_char(b11_utilbruta,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(135,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(140,'ACCESORIOS','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(145,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(150,'Precio:',to_char(b21_factacces,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(155,'Costo:',to_char(b22_costoacces,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(160,'Utilidad Bruta:',to_char(b23_utilacces,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(165,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(170,'F & I','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(175,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(180,'Gastos Administracion:',to_char(b25_gastosadmin,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(185,'Seguro:',to_char(b26_comseguro,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(190,'Extras:',to_char(b27_extras,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(195,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(200,'Base para Comisiones:',to_char(b12_base,'fm999G990D00'),'');
	insert into tmpRows (orden,variable,valor1,valor2) values(205,'','','          %');
	insert into tmpRows (orden,variable,valor1,valor2) values(210,'Comision Base:',to_char(b30_comisbase,'fm999G990D00'),to_char(b50_comisbase,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(215,'Comision Edad:',to_char(b31_comisedad,'fm999G990D00'),to_char(b51_comisedad,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(220,'Nota Descuento:',to_char(b32_descto,'fm999G990D00'),to_char(b52_notadescto,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(225,'Gastos Administración:',to_char(b33_comgastosadmon,'fm999G990D00'),to_char(b53_comgastosadmon,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(230,'Accesorios:',to_char(b34_comacces,'fm999G990D00'),to_char(b54_comubacces,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(235,'Extras:',to_char(b35_comextras,'fm999G990D00'),to_char(b55_comextras,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(240,'Semana:',to_char(b36_comcomisem,'fm999G990D00'),to_char(b56_combonosem,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(245,'Línea de Vehículo:',to_char(b37_bonolinea,'fm999G990D00'),to_char(b57_combonolinea,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(250,'Seguro:',to_char(b38_seguro,'fm999G990D00'),to_char(b58_comseguros,'fm999G990D00'));
	insert into tmpRows (orden,variable,valor1,valor2) values(255,'','','');
	insert into tmpRows (orden,variable,valor1,valor2) values(260,'Total de Comisiones:',to_char(b39_comtotal,'fm999G990D00'),'');


	return query select tr.orden,tr.variable,tr.valor1,tr.valor2 from tmpRows tr order by tr.orden;

/*
rec_E_INF
rec_F_UV,rec_G_COMISMOV,rec_H_COMISMOV2,rec_I_COMISADIS,
rec_J_PEDIDO,rec_K_IPVA,rec_S_MS,rec_O_VESQ
rec_P_VESQVEH,rec_Q_PORCENTAJES,rec_T_TIPOCOMIS,rec_U_VOBJLINEA
rec_V_IV

 OPEN(E,KDINF,F,KDUV,G,KDCOMISMOV,H,KDCOMISMOV2,I,KDCOMISADIS,
 J,KDPEDIDO,K,KDIPVA,S,KDMS,O,KDVESQ,P,KDVESQVEH,
 Q,KDPORCENTAJES,T,KDTIPOCOMIS,U,KDVOBJLINEA,V,KDIV)
  
 */
end;
$function$
