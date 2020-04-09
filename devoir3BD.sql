--Binome:
--   EL FERDAOUSSI Hanane, EL GUERCHI Houssam
--DEVOIR N°03 BASE DE DONNEES AVANCEE

-------------------------- PROCEDURES --------------------------
-- Q1
set serveroutput on;
 
CREATE OR REPLACE PROCEDURE Ajoutpilote ( 
v_num pilote.nopilot%type,
 v_nom pilote.nom%type,
 v_ville pilote.ville%type,
 v_sal pilote.sal%type,
 v_comm pilote.comm%type,
 v_embauche pilote.embauche%type) 
	IS 
 
	BEGIN 
		
 
		insert into pilote (nopilot,nom,ville,sal,comm,embauche) 
		values(v_num, v_nom,  v_ville,v_sal,v_comm,v_embauche);
        dbms_output.put_line('pilote crÈe avec succÈs!');
 
  EXCEPTION
  WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE (SQLERRM);
 RAISE;
END;
/

-- Q2


set serveroutput on;
  
CREATE OR REPLACE PROCEDURE SupprimePilote ( v_num pilote.nopilot%type)

	IS 
 
	BEGIN 
 
        delete from pilote where nopilot=v_num;
        dbms_output.put_line('pilote supprimÈ avec succÈs!');
 
  EXCEPTION
  WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE (SQLERRM);
 RAISE;
END;
/

-- Q3

set serveroutput on;
 CREATE OR REPLACE PROCEDURE affichePilote_N(n number)
 IS
  cursor c1
   IS
   select *  from PILOTE
   WHERE rownum <= n;
   t_pilote PILOTE%ROWTYPE;
 BEGIN
Open c1;
LOOP
fetch c1 into t_pilote;
EXIT WHEN c1%NOTFOUND;
dbms_output.put_line(t_pilote.nopilot);
END LOOP;
close c1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE (SQLERRM);
 RAISE;
 END;
 /
 

-------------------------- FONCTIONS --------------------------

set serveroutput on;

create function nombreMoyenHeureVol(famille in varchar2) return number
 is
 cursor cc
   IS
   select avg(avion.nbhvol) from avion group by Avion.type  having avion.type=famille;
   nbmoy number;
begin
Open cc;
LOOP
fetch cc into nbmoy;
EXIT WHEN c1%NOTFOUND;
dbms_output.put_line(nbmoy);
return nbmoy;
END LOOP;
close cc;
   EXCEPTION
  WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE (SQLERRM);
 RAISE;


-------------------------- Paquetages --------------------------
-- 1)
create package gest_pilote AS
    cursor cpilote;
    procedure proc_comm (numpilote pilote.nopilot%type);
    function nbr_pilote () return number;
    procedure supp_pilote (numpilote pilote.nopilot%type);
    function moy_vol (nom avion.nom%type) return number;
    procedure modif_pilote (numpilote pilote.nopilot%type ,nom pilote.nom%type, ville pilote.ville%type, salaire pilote.sal%type);
end gest_pilote;

create package body gest_pilote as

    cursor cpilote is select nopilot, nom, ville, sal from pilote;

    procedure proc_comm(numpilote pilote.nopilot%type) is
        v_salaire pilote.sal%type;
        v_commission pilote.comm%type;
        comm_err exception;
        begin
            select sal, comm into v_salaire, v_commission from pilote where nopilot = numpilote;
            if (v_commission > v_salaire) then raise comm_err;
        exception
            when comm_err then dbms_output.put_line("La commission est superieure du salaire");
        end;
    end proc_comm;

    function nbr_pilote () return number is
        v_nbr_pilote number;
        begin
            select count(*) into v_nbr_pilote from pilote where nom like 'Ah%';
            return v_nbr_pilote;
        end,
    end nbr_pilote;

    procedure supp_pilote (numpilote pilote.nopilot%type) is 
        begin
            delete from pilote where nopilot = numpilote;
        end;
    end supp_pilote;

    function moy_vol (nom avion.nom%type) return number is
        v_moy_vol number;
        begin
            select avg(abs(vol.dep_h - vol.ar_h)) into v_moy_vol from vol
            join affectation on vol.novol = affectation.vol
            join avion on affectation.avion = avion.nuavion
            where avion.nom = nom;
            return v_moy_vol;
        end;
    end moy_vol;

    procedure modif_pilote (numpilote pilote.nopilot%type ,nv_nom pilote.nom%type, nv_ville pilote.ville%type, nv_salaire pilote.sal%type) is
        begin
            update pilote set nom = nv_nom, ville = nv_ville, sal = nv_salaire
            where nopilot = numpilote;
        end;
    end modif_pilote;


end gest_pilote;

-- 2)
create package pkgCollectionPilote as
    type tab_pilotes is table of pilote%ROWTYPE;
    les_pilotes tab_pilotes;
    procedure garnirTabo();
    function maximum(sal1 pilote.sal%type, sal2 pilote.sal%type) return pilote.sal%type;
    function salMax(p_tab_pilote tab_pilotes) return pilote.sal%type;
    procedure tritable(p_tab_pilotes tab_pilotes);
end pkgCollectionPilote;

-- 3)
create package body pkgCollectionPilote as

    les_pilotes := tab_pilotes();

    procedure garnirTabo() is
        cursor c_pilote is select * from pilote;
        begin
            for v_pilote in c_pilote loop
                les_pilotes.EXTEND;
                les_pilotes(les_pilotes.LAST) := v_pilote;
            end loop;
        end;
    end garnirTabo;

    function maximum(sal1 pilote.sal%type, sal2 pilote.sal%type)
    return pilote.sal%type
    is
        begin
            if (sal1 >= sal2) then return sal1;
            else return sal2;
            end if;
        end;
    end maximum;

    function salMax(p_tab_pilote tab_pilotes)
    return pilote.sal%type
    is
        temp pilote.sal%type;
        begin
            maxSal := les_pilotes(les_pilotes.FIRST).sal;
            for i in les_pilotes.FIRST .. les_pilotes.LAST
            loop
                if (maxSal < les_pilotes(i).sal) then
                    maxSal := les_pilotes(i).sal;
                end if;
            end loop;
            return maxSal;
        end;
    end salMax;

end pkgCollectionPilote;
/