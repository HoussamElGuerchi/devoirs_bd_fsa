--Binome:
--      EL FERDAOUSSI Hanane, EL GUERCHI Houssam
--      DEVOIR N°03 BASE DE DONNEES AVANCEE

----------------------------------------------------------------------------------------------------

-- Q1
create or replace trigger rest_dml_pilote before
insert or update or delete on pilote
begin
    if (to_char(sysdate, 'HH24') between ('08' and '18')) then
        if inserting then RAISE_APPLICATION_ERROR(-20501, 'Insertion impossible à cette heure');
        elsif updating then RAISE_APPLICATION_ERROR(-20502, 'Mise à jour impossible à cette heure');
        elsif deleting then RAISE_APPLICATION_ERROR(-20503, 'Suppression impossible à cette heure');
        end if;
    end if;
end;

-- Q2
create or replace trigger trig_audit after
insert or update or delete on pilote
for each row
begin
    insert into audit_pilote_table
    values(USER, SYSDATE, :OLD.nopilot, :OLD.nom, :NEW.nom, :OLD.comm, :NEW.comm, :OLD.sal, :NEW.sal);
end;

-- Q3
create or replace trigger trig_comm after
insert or update on pilote
for each row
begin
    update pilote set comm = (sal*(20/100)) where pilote.comm = :NEW.comm;
end;

-- Q4
create or replace trigger rest_dml_pilote before
insert or update or delete on pilote
declare
    v_sal pilote.sal%TYPE;
    v_sal_red pilote.sal%TYPE;
    v_sal_aug pilote.sal%TYPE;
begin
    v_sal := :NEW.sal;
    v_sal_red := :OLD.v_sal - (:OLD.v_sal*(10/100));
    v_sal_aug := :OLD.v_sal + (:OLD.v_sal*(10/100));
    if ( v_sal < v_sal_red or v_sal > v_sal_aug ) then
        if inserting then RAISE_APPLICATION_ERROR(-20501, 'Impossible d augmenté ou réduit le salaire de plus de 10%');
        elsif updating then RAISE_APPLICATION_ERROR(-20502, 'Impossible d augmenté ou réduit le salaire de plus de 10%');
        end if;
    end if;
end;

-- Q5
create or replace trigger Ajout-pilote  
before  insert on Pilote
begin
EXECUTE IMMEDIATE 'revoke INSERT on pilote from user';
dbms_output.put_line('Utilisateur non autorisé!!');
END;
/

-- Q6
create or replace trigger verif_nhvol  
after  insert or update on Avion
declare moyenneheures number;
begin
 select avg(NBHVOL)into moyenneheures from Avion ;
 if moyenneheures>200000 
 THEN
dbms_output.put_line('le nombre moyen d’heure de vol est trop élevé!!');
end if;
END;
/

-- Q7
CREATE OR REPLACE TRIGGER LOGON_TRIG
AFTER update ON Pilote
for each row
DECLARE nbmodif number ;
t number;
BEGIN
select count(ROW) into t from dual;
nbmodif := nbmodif+t;
END;
/



-- Q8
ALTER TRIGGER verif_nhvol DISABLE;
ALTER TABLE nom_table DISABLE ALL TRIGGERS;
