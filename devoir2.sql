--Binome:
--   EL FERDAOUSSI Hanane, EL GUERCHI Houssam
--DEVOIR N°02 BASE DE DONNEES AVANCEE
--Question C7:
DECLARE
CURSOR c_pilote IS
SELECT nom, sal, comm
FROM pilote
WHERE nopilot BETWEEN 1280 AND 1999 FOR UPDATE;
 v_nom pilote.nom%type;
 v_sal pilote.sal%type;
 v_comm pilote.comm%type;
BEGIN
    open c_pilote;
    loop;
    fetch c_pilote into v_nom, v_sal, v_com;
    exit when c_pilote%NOTFOUND;
    if (v_com > v_sal) THEN
        update pilote set sal = (v_sal + v_com), com = 0 where current of c_pilote;
    elsif (v_com is null) THEN
        delete from pilote where current of c_pilote
    end if;
    end loop;
    close c_pilote;
END;

--D- Création des vues:
--Question D1:
DECLARE
BEGIN
    CREATE OR REPLACE VIEW v-pilote AS
    SELECT * FROM pilote WHERE ville = 'PARIS'
    WITH READ_ONLY;
END;

--Question D2
--On peut pas modifier les salaire car on a ajouté la clause WITH READ ONLY

--Question D3
DECLARE
BEGIN
    CREATE OR REPLACE VIEW dervol AS
    SELECT vol, max(date_vol) from affectation
    GROUP BY vol;
END;

--Question D4
DECLARE
BEGIN
    CREATE OR REPLACE VIEW cr-pilote AS
    SELECT * from pilote
    WHERE (ville = 'PARIS' and com not null) OR (ville != 'PARIS' and com is null)
    WITH CHECK OPTION;
END;

--Question D5
DECLARE
BEGIN
    CREATE OR REPLACE VIEW cr-pilote AS
    SELECT * from pilote
    WHERE (ville = 'PARIS' and com not null) OR (ville != 'PARIS' and com is null)
    WITH CHECK OPTION;
END;