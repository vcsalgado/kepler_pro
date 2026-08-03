CREATE OR REPLACE PROCEDURE keplersc.log_transac_insert(tran_id text, usuario text, referencia text, paso text, resultado boolean, mensaje text, tipo text, INOUT pr_resultado xml)
 LANGUAGE plpgsql
AS $procedure$
declare 
	xmlresultado xml;
	strValor text;
	strFile text;
	strTmp text;
begin
	--TO DO: Desarrollar escribir log en disco, el nombre del archivo se debera crear 
	--       como log_k80AAMMDD, lo que indica que será de creacion diaria para efecto
	--		 de administracion de espacio.
	begin
	--Guardar log en DB
	insert into keplersc.log_transac (tran_id,usuario,referencia,paso,resultado,mensaje,tipo)
		values(tran_id,usuario,referencia,paso,resultado,mensaje,tipo);
	
	--Guardar log en disco
		strFile := 'C:\Tmp\Log\kp_' || 
			substring(EXTRACT(YEAR FROM CURRENT_TIMESTAMP)::text,3,2) ||
			lpad(EXTRACT(month FROM CURRENT_TIMESTAMP)::text,2,'0') ||
			'.log';
		strValor := '''findstr "^" >> C:\Basura\salida.txt''';

		strTmp:=concat(tipo, tran_id, usuario, referencia, paso, resultado, mensaje);
		copy (select * from keplersc.kdms where c1='01') to 'C:\Basura\BDLogErr.txt'; 
	exception
	when others then
		--Cacha el error para permitir seguir con el siguiente comando
	end;
	pr_resultado :=  xmlforest('1' AS resultado, '' AS mensaje, '' as valores);
exception
	when others then
	pr_resultado :=  xmlforest('0' AS resultado, '['|| sqlstate || '] ' || sqlerrm AS mensaje, 'log_transac_insert' as valores);
end;
$procedure$
