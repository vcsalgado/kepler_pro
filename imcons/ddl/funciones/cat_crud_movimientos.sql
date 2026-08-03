CREATE OR REPLACE FUNCTION keplersc.cat_crud_movimientos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de kdmm
--Autor: Gad Miranda
--Fecha: 10/02/2023
--Bitacora de cambios
--06/03/2026 Miriam Santana: Agregar columnas faltantes y Registro de movimiento en bitacora

declare
	--Variables de definicion de documento
	sucursal_id text = '';	--col_sucursal
	k_genero_crud text = ''; --c1
	k_naturaleza_crud text = ''; --c2
	k_grupo_crud int = 0; --c3
	k_tipo_crud int = 0; --c4
	k_desc_mov_crud text =''; --c5
	k_folio_crud text =''; --c17
	k_afecta_conta text=''; --c6
	k_afecta_cxc text='';  --c7
	k_c8 text='';
	k_c9 text='';
	k_c10 text='';
	k_c11 text='';
	k_c12 text='';
	k_c13 text='';
	k_c14 text='';
	k_c15 text='';
	k_c16 text='';
	k_c18 text='';
	k_c19 text='';
	k_c20 text='';
	k_c21 text='';
	k_c22 text='';
	k_c23 text='';
	k_c24 text='';
	k_c25 int = 0;
	k_c26 int = 0;
	k_c27 text='';
	k_c28 text='';
	k_c29 text='';
	k_c30 text='';
	k_c31 text='';
	k_c32 text='';
	k_c33 text='';
	k_c34 text='';
	k_c35 text='';
	k_c36 text='';
	k_c37 text='';
	k_c38 text='';
	k_c39 text='';
	k_c40 text='';
	k_c41 text='';
	k_c42 text='';
	k_c43 text='';
	k_c44 text='';
	k_c45 text='';
	k_c46 text='';
	k_c47 text='';
	k_c48 text='';
	k_c49 text='';
	k_c50 text='';
	k_c51 text='';
	k_c52 text='';
	k_c53 text='';
	k_c54  text='';
	k_c55  text='';
	k_c56  text='';
	k_c57  text='';
	k_c58  text='';
	k_c59  text='';
	k_c60  text='';
	k_c61  text='';
	k_c62  text='';
	k_c63  text='';
	k_c64 text='';
	k_c65 text='';
	k_c66 text='';
	k_c67 text='';
	k_c68 text='';
	k_c69 text='';
	k_c70 text='';
	k_c71 text='';
	k_c72 text='';
	k_c73 text='';
	k_c74 text='';
	k_c75 text='';
	k_c76 text='';
	k_c77 text='';
	k_c80 text='';
	k_c81 text='';
	k_c82 text='';
	k_c83 text='';
	k_c84 text='';
	k_c85 text='';
	k_c86 text='';
	k_c87 text='';
	k_c88 text='';
	k_c89 text='';
	k_c90 text='';
	k_c91 text='';
	k_c92 text='';
	k_c93 text='';
	k_c94 text='';
	k_c95 text='';
	k_c100 text='';
	k_c101 date;
	k_c102 date;
	k_folio_manual text='';
	crud text = '';

	--MSS 02032026 Grabar en bitacora
	usuario_movto text;
	operacion_desc text = '';
	detalle_movto text = '';
	strValor text;
	xmlUsr xml;	
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	k_genero_crud := coalesce((xpath('//document/k_genero_crud/r0/text()', dataxml))[1],'');
	k_naturaleza_crud := coalesce((xpath('//document/k_naturaleza_crud/r0/text()', dataxml))[1],'');		
	k_grupo_crud :=(xpath('//document/k_grupo_crud/text()', dataxml))[1];	
	k_tipo_crud := (xpath('//document/k_tipo_crud/text()', dataxml))[1];	
	k_desc_mov_crud := coalesce((xpath('//document/k_desc_mov_crud/text()', dataxml))[1],'');

	--Movimiento				--MSS 02032026 Grabar en bitacora
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];

	--Validacion de datos minimos 
	if k_genero_crud = '' then
		raise exception 'No se proporciono el Genero del Movimiento';
	end if;
	if k_naturaleza_crud = '' then
		raise exception 'No se proporciono la Naturaleza del Movimiento';
	end if;
--	if k_grupo_crud = '' then
--		raise exception 'No se proporciono el Grupo del Movimiento';
--	end if;
--	if k_tipo_crud = '' then
--		raise exception 'No se proporciono  el Tipo del Movimiento';
--	end if;
	if k_desc_mov_crud = '' then
		raise exception 'No se proporciono la Descripcion del Movimiento';
	end if;

	k_folio_crud := (xpath('//document/k_folio_crud/text()', dataxml))[1];
	k_afecta_conta := coalesce((xpath('//document/k_afecta_conta/text()', dataxml))[1],'N');
	k_afecta_cxc := coalesce((xpath('//document/k_afecta_cxc/text()', dataxml))[1],'N');
	k_c8 := coalesce((xpath('//document/c8/text()', dataxml))[1],'N');
	k_c9 := coalesce((xpath('//document/c9/text()', dataxml))[1],'N');
	k_c10 := coalesce((xpath('//document/c10/text()', dataxml))[1],'N');
	k_c11 := coalesce((xpath('//document/c11/text()', dataxml))[1],'N');
	k_c12 := coalesce((xpath('//document/c12/text()', dataxml))[1],'N');
	k_c13 := coalesce((xpath('//document/c13/text()', dataxml))[1],'N');
	k_c14 := coalesce((xpath('//document/c14/text()', dataxml))[1],'N');
	k_c15 := coalesce((xpath('//document/c15/text()', dataxml))[1],'');
	k_c16 := coalesce((xpath('//document/c16/text()', dataxml))[1],'');
	k_c18 := coalesce((xpath('//document/c18/text()', dataxml))[1],'');
	k_c19 := coalesce((xpath('//document/c19/text()', dataxml))[1],'');
	k_c20 := coalesce((xpath('//document/c20/text()', dataxml))[1],'');
	k_c21 := coalesce((xpath('//document/c21/text()', dataxml))[1],'');
	k_c22 := coalesce((xpath('//document/c22/text()', dataxml))[1],'');
	k_c23 := coalesce((xpath('//document/c23/text()', dataxml))[1],'');
	k_c24 := coalesce((xpath('//document/c24/text()', dataxml))[1],'');

	k_c25 := coalesce((xpath('//document/c25/text()', dataxml))[1],'0');
	k_c26 := coalesce((xpath('//document/c26/text()', dataxml))[1],'0');
	k_c27 := coalesce((xpath('//document/c27/text()', dataxml))[1],'');
	k_c28 := coalesce((xpath('//document/c28/text()', dataxml))[1],'');
	k_c29 := coalesce((xpath('//document/c29/text()', dataxml))[1],'');
	k_c30 := coalesce((xpath('//document/c30/text()', dataxml))[1],'');
	k_c31 := coalesce((xpath('//document/c31/text()', dataxml))[1],'');
	k_c32 := coalesce((xpath('//document/c32/text()', dataxml))[1],'0');
	k_c33 := coalesce((xpath('//document/c33/text()', dataxml))[1],'');
	k_c34 := coalesce((xpath('//document/c34/text()', dataxml))[1],'');
	k_c35 := coalesce((xpath('//document/c35/text()', dataxml))[1],'');
	k_c36 := coalesce((xpath('//document/c36/text()', dataxml))[1],'');
	k_c37 := coalesce((xpath('//document/c37/text()', dataxml))[1],'');
	k_c38 := coalesce((xpath('//document/c38/text()', dataxml))[1],'');
	k_c39 := coalesce((xpath('//document/c39/text()', dataxml))[1],'');
	k_c40 := coalesce((xpath('//document/c40/text()', dataxml))[1],'');
	k_c41 := coalesce((xpath('//document/c41/text()', dataxml))[1],'');
	k_c42 := coalesce((xpath('//document/c42/text()', dataxml))[1],'N');
	k_c43 := coalesce((xpath('//document/c43/text()', dataxml))[1],'N');
	k_c44 := coalesce((xpath('//document/c44/text()', dataxml))[1],'');
	k_c45 := coalesce((xpath('//document/c45/text()', dataxml))[1],'');
	k_c46 := coalesce((xpath('//document/c46/text()', dataxml))[1],'N');
	k_c47 := coalesce((xpath('//document/c47/text()', dataxml))[1],'');
	k_c48 := coalesce((xpath('//document/c48/text()', dataxml))[1],'N');
	k_c49 := coalesce((xpath('//document/c49/text()', dataxml))[1],'0');
	k_c50 := coalesce((xpath('//document/c50/text()', dataxml))[1],'0');
	k_c51 := coalesce((xpath('//document/c51/text()', dataxml))[1],'');
	k_c52 := coalesce((xpath('//document/c52/text()', dataxml))[1],'');
	k_c53 := coalesce((xpath('//document/c53/text()', dataxml))[1],'');

	k_c54 :=  coalesce((xpath('//document/c54/text()', dataxml))[1],'0');
	k_c55 :=  coalesce((xpath('//document/c55/text()', dataxml))[1],'0');
	k_c56 :=  coalesce((xpath('//document/c56/text()', dataxml))[1],'0');
	k_c57 :=  coalesce((xpath('//document/c57/text()', dataxml))[1],'0');
	k_c58 :=  coalesce((xpath('//document/c58/text()', dataxml))[1],'0');
	k_c59 :=  coalesce((xpath('//document/c59/text()', dataxml))[1],'0');
	k_c60 :=  coalesce((xpath('//document/c60/text()', dataxml))[1],'0');
	k_c61 :=  coalesce((xpath('//document/c61/text()', dataxml))[1],'0');
	k_c62 :=  coalesce((xpath('//document/c62/text()', dataxml))[1],'0');
	k_c63 :=  coalesce((xpath('//document/c63/text()', dataxml))[1],'0');

	k_c64 :=  coalesce((xpath('//document/c64/text()', dataxml))[1],'');
	k_c65 :=  coalesce((xpath('//document/c65/text()', dataxml))[1],'0');

	k_c66 := coalesce((xpath('//document/c66/text()', dataxml))[1],'');
	k_c67 := coalesce((xpath('//document/c67/text()', dataxml))[1],'');
	k_c68 := coalesce((xpath('//document/c68/text()', dataxml))[1],'');
	k_c69 := coalesce((xpath('//document/c69/text()', dataxml))[1],'');

	k_c70 :=  coalesce((xpath('//document/c70/text()', dataxml))[1],'0');

	k_c71 := coalesce((xpath('//document/c71/text()', dataxml))[1],'');
	k_c72 := coalesce((xpath('//document/c72/text()', dataxml))[1],'');
	k_c73 := coalesce((xpath('//document/c73/text()', dataxml))[1],'');
	k_c74 := coalesce((xpath('//document/c74/text()', dataxml))[1],'');
	k_c75 := coalesce((xpath('//document/c75/text()', dataxml))[1],'');
	k_c76 := coalesce((xpath('//document/c76/text()', dataxml))[1],'');
	k_c77 := coalesce((xpath('//document/c77/text()', dataxml))[1],'');
	k_c80 := coalesce((xpath('//document/c80/text()', dataxml))[1],'');
	k_c81 := coalesce((xpath('//document/c81/text()', dataxml))[1],'');
	k_c82 := coalesce((xpath('//document/c82/text()', dataxml))[1],'');
	k_c83 := coalesce((xpath('//document/c83/text()', dataxml))[1],'');
	k_c84 := coalesce((xpath('//document/c84/text()', dataxml))[1],'');
	k_c85 := coalesce((xpath('//document/c85/text()', dataxml))[1],'');
	k_c86 := coalesce((xpath('//document/c86/text()', dataxml))[1],'');
	k_c87 := coalesce((xpath('//document/c87/text()', dataxml))[1],'');
	k_c88 := coalesce((xpath('//document/c88/text()', dataxml))[1],'');
	k_c89 := coalesce((xpath('//document/c89/text()', dataxml))[1],'');
	k_c90 := coalesce((xpath('//document/c90/text()', dataxml))[1],'');
	k_c91 := coalesce((xpath('//document/c91/text()', dataxml))[1],'');
	k_c92 :=coalesce((xpath('//document/c92/text()', dataxml))[1],'');
	k_c93 := coalesce((xpath('//document/c93/text()', dataxml))[1],'');	
	k_c94 := coalesce((xpath('//document/c94/text()', dataxml))[1],'');
	k_c95 := coalesce((xpath('//document/c95/r1/text()', dataxml))[1],'');
	k_folio_manual := coalesce((xpath('//document/folio_manual/text()', dataxml))[1],'');
	k_c100 :=coalesce((xpath('//document/c100/text()', dataxml))[1],'');
--	k_c101 := coalesce((xpath('//document/c101/text()', dataxml))[1],''); --'1990-01-01 00:00:00.000';
--	k_c102 := coalesce((xpath('//document/c102/text()', dataxml))[1],''); --'1800-01-01 00:00:00.000';

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

--raise exception 'Error inyectado...';
raise notice 'VAR c1:%',k_afecta_cxc;

	if crud = 'NUEVO' then
		insert into keplersc.kdmm
			(c1,c2,c3,c4,c5,
			c6,c7,c8,c9,c10,
			c11,c12,c13,c14,c15,
			c16,c17,c18,c19,c20,
			c21,c22,c23,c24,c25,
			c26,c27,c28,c29,c30,
			c31,c32,c33,c34,c35,
			c36,c37,c38,c39,c40,
			c41,c42,c43,c44,c45,
			c46,c47,c48,c49,c50,
			c51,c52,c53,c54,c55,
			c56,c57,c58,c59,c60,
			c61,c62,c63,c64,c65,
			c66,c67,c68,c69,c70,
			c71,c72,c73,c74,c75,
			c76,c77,c80,
			c81,c82,c83,c84,c85,
			c86,c87,c88,c89,c90,
			c91,c92,c93,c94,c95,
			c100,
			c101,c102,col_sucursal,folio_manual) 
		values(	
			k_genero_crud,k_naturaleza_crud,k_grupo_crud,k_tipo_crud,k_desc_mov_crud,
			k_afecta_conta,k_afecta_cxc,k_c8,k_c9,k_c10,
			k_c11,k_c12,k_c13,k_c14,k_c15,
			k_c16,k_folio_crud,k_c18,k_c19,k_c20,
			k_c21,k_c22,k_c23,k_c24,k_c25::int,
			k_c26::int,k_c27,k_c28,k_c29,k_c30,
			k_c31,k_c32::int,k_c33,k_c34,k_c35,
			k_c36,k_c37,k_c38,k_c39,k_c40,
			k_c41,k_c42,k_c43,k_c44,k_c45,
			k_c46,k_c47,k_c48,k_c49::int,k_c50::int,
			k_c51,k_c52,k_c53,k_c54::int,k_c55::int,
			k_c56::int,k_c57::int,k_c58::int,k_c59::int,k_c60::int,
			k_c61::int,k_c62::int,k_c63::int,k_c64,k_c65::int,
			k_c66,k_c67,k_c68,k_c69,k_c70::int,
			k_c71,k_c72,k_c73,k_c74,k_c75,
			k_c76,k_c77,k_c80,
			k_c81,k_c82,k_c83,k_c84,k_c85,
			k_c86,k_c87,k_c88,k_c89,k_c90,
			k_c91,k_c92,k_c93,k_c94,k_c95,
			k_c100,
			k_c101,k_c102,sucursal_id,k_folio_manual);
	end if;

	if crud = 'MODIFICAR' then
		--MSS 02032026 Agregar columnas faltantes	
		update keplersc.kdmm as m
			set c5=k_desc_mov_crud,
			c6=k_afecta_conta,c7=k_afecta_cxc,c8=k_c8,c9=k_c9,c10=k_c10,
			c11=k_c11,c14=k_c14,c15=k_c15,
			c16=k_c16,c18=k_c18,c19=k_c19,c20=k_c20,
			c21=k_c21,c22=k_c22,c23=k_c23,c24=k_c24,c25=k_c25::int,
			c26=k_c26::int,c30=k_c30,
			c33=k_c33,c34=k_c34,c35=k_c35,
			c36=k_c36,c37=k_c37,c38=k_c38,c39=k_c39,c40=k_c40,
			c41=k_c41,
			c47=k_c47,
			c51=k_c51,c54=k_c54::int,c55=k_c55::int,
			c56=k_c56::int,c57=k_c57::int,c58=k_c58::int,c59=k_c59::int,c60=k_c60::int,
			c61=k_c61::int,c62=k_c62::int,c63=k_c63::int,c64=k_c64,c65=k_c65::int,
			c66=k_c66,c67=k_c67,
			c71=k_c71,c72=k_c72,c73=k_c73,c74=k_c74,c75=k_c75,
			c76=k_c76,c77=k_c77,c80=k_c80,
			c86=k_c86,c87=k_c87,c88=k_c88,c89=k_c89,
			c92=k_c92,c94=k_c94,c95=k_c95,
			folio_manual=k_folio_manual

			where col_sucursal=sucursal_id and c1=k_genero_crud and c2=k_naturaleza_crud and c3=k_grupo_crud::int and c4=k_tipo_crud::int;	

	end if;

	--MSS 06032026: Registro de movimiento en bitacora
	operacion_desc := crud;
	detalle_movto := operacion_desc || ' ' || k_genero_crud || ' ' || k_naturaleza_crud || ' ' || k_grupo_crud || ' ' || k_tipo_crud || ' ' || k_desc_mov_crud;
	select xmlforest(usuario_movto as usuario, current_date as fecha, TO_CHAR(NOW(), 'HH24:MI:SS') as hora,
				sucursal_id as sucursal, k_genero_crud as genero, k_naturaleza_crud as naturaleza, k_grupo_crud as grupo, k_tipo_crud as tipo, 'KDMM' as folio,
				operacion_desc as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;					
		
		
		select '<document>'||strValor||'</document>' into strValor;
		xmlUsr := strValor::xml;
		
		select * into resultado, mensaje, adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
		--raise notice '%',sucursal_id;	
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;	

	resultado := 1;
	mensaje := 'Registro agregado:' || k_genero_crud || k_naturaleza_crud || k_grupo_crud || k_tipo_crud;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_movimientos() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
