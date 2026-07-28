CREATE OR REPLACE FUNCTION keplersc.ser_paquetes_copia(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza la copia de paquetes
--Autor: Victor Salgado
--Fecha: 20/08/2025
--Bitacora de cambios

declare
	--Variables de definicion de documento
	k_marca_origen text = '';
	k_modelo_origen text = '';
	k_paquete_origen text = '';
	k_modelo_inicial text = '';
	k_modelo_final text = '';

	crud text = '';
	totReg numeric(1);
	recModelos record;
	recPaq record;
	recPaqM record;
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 

	k_marca_origen := (xpath('//document/k_marca_origen/text()', dataxml))[1];
	k_modelo_origen := (xpath('//document/k_modelo_origen/text()', dataxml))[1];
	k_paquete_origen := (xpath('//document/k_paquete_origen/text()', dataxml))[1];
	k_modelo_inicial := (xpath('//document/k_modelo_inicial/text()', dataxml))[1];
	k_modelo_final := (xpath('//document/k_modelo_final/text()', dataxml))[1];

	for recModelos in select * from keplersc.kdmodelos where c1=k_marca_origen and c2 collate "C" >=k_modelo_inicial and c2 collate "C" <=k_modelo_final and c2<>k_modelo_origen
	loop
		delete from keplersc.kdspaq paq where paq.c1=recModelos.c1 and paq.c2=recModelos.c2 and paq.c4=k_paquete_origen;
		delete from keplersc.kdspaqm paqm where paqm.c1=recModelos.c1 and paqm.c2=recModelos.c2 and paqm.c4=k_paquete_origen;

		select * into recPaq from keplersc.kdspaq where c1= k_marca_origen and c2=k_modelo_origen and c4=k_paquete_origen; 		
		insert into keplersc.kdspaq values(recModelos.c1,recModelos.c2, recPaq.c3, recPaq.c4,recPaq.c5,recPaq.c6,recPaq.c7,recPaq.c8,recPaq.c9,recPaq.c10,recPaq.c11);

		for recPaqM in select * from keplersc.kdspaqm where c1= k_marca_origen and c2=k_modelo_origen and c4=k_paquete_origen
		loop
			insert into keplersc.kdspaqm values(recModelos.c1,recModelos.c2, recPaqM.c3,recPaqM.c4,recPaqM.c5,recPaqM.c6,recPaqM.c7);
		end loop;

	end loop;

/*
OPEN(C,KDCATPAQ,D,KDSPAQ,E,KDSPAQM,F,KDMARCAS,G,KDMODELOS,H,KDSPAQ,I,KDSPAQM)
SUB EJECUTA
	VIEW(G) WHILE G1=A1 AND G2>=A4 AND G2<=A5
  		IF G2><A2 THEN
   			IF BUS(H,1,0,G1,G2,A3)>0 THEN 
				DEL(H): 
			ENDIF
   			DOWHILE BUS(I,1,0,G1,G2,A3,ULT)>0
    			DEL(I)
   			LOOP
   			IF BUS(D,1,0,A1...A3)>0 THEN 
				INS(H,G1,G2,"",D4...D11): 
			ENDIF
   			VIEW(E) WHILE E1=A1 AND E2=A2 AND E4=A3
    			INS(I,G1,G2,"",E4,"",E6,E7)
   			LOOP
  		ENDIF
 	LOOP
ENDSUB
*/

	resultado := 1;
	mensaje := 'Copia realizada.' ;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_paquetes_copia() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
