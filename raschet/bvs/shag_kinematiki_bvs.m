function obnovlennoe_sostoyanie = shag_kinematiki_bvs(sostoyanie_bvs, shag_vremeni, oblast_poleta)

sostoyanie_bvs = proverit_sostoyanie_bvs(sostoyanie_bvs);
oblast_poleta = proverit_oblast_poleta(oblast_poleta, 'области полета');
shag_vremeni = proverit_shag_vremeni(shag_vremeni);

if ~sostoyanie_bvs.rabotosposoben
    obnovlennoe_sostoyanie = sostoyanie_bvs;
    return
end

novoe_polozhenie = sostoyanie_bvs.polozhenie + sostoyanie_bvs.skorost * shag_vremeni;
[novoe_polozhenie, novaya_skorost] = otrazit_tochku_ot_granic( ...
    novoe_polozhenie, ...
    sostoyanie_bvs.skorost, ...
    oblast_poleta);

obnovlennoe_sostoyanie = sostoyanie_bvs;
obnovlennoe_sostoyanie.polozhenie = novoe_polozhenie;
obnovlennoe_sostoyanie.skorost = novaya_skorost;
obnovlennoe_sostoyanie = proverit_sostoyanie_bvs(obnovlennoe_sostoyanie);
end

function shag_vremeni = proverit_shag_vremeni(shag_vremeni)
if ~isnumeric(shag_vremeni) || ~isscalar(shag_vremeni) || ~isfinite(shag_vremeni)
    error('%s', 'Шаг кинематики должен быть конечным числом.');
end

shag_vremeni = double(shag_vremeni);
if shag_vremeni <= 0
    error('%s', 'Шаг кинематики должен быть положительным.');
end
end
