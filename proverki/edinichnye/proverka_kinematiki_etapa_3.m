function rezultat = proverka_kinematiki_etapa_3(koren_proekta)
put_k_scenariyu = fullfile( ...
    koren_proekta, 'opyty', 'scenarii', 'bazovye', 'stroi_malyi.json');

if ~isfile(put_k_scenariyu)
    error('%s', sprintf( ...
        'Не найден сценарий для проверки кинематики этапа 3: %s', ...
        put_k_scenariyu));
end

scenarii = zagruzit_scenarii(put_k_scenariyu);
sostoyaniya_bvs = sozdat_sostoyanie_bvs_iz_scenariya(scenarii);
rezultat = raschet_passivnoi_kinematiki(scenarii);

if numel(rezultat.vremya) < 11
    error('%s', 'Для проверки этапа 3 требуется не меньше 10 шагов кинематики.');
end

if rezultat.chislo_bvs ~= 5
    error('%s', 'В сценарии stroi_malyi для этапа 3 должно быть 5 БВС.');
end

if ~all(isfinite(rezultat.polozheniya(:)))
    error('%s', 'В результате пассивной кинематики обнаружены неконечные положения.');
end

if ~all(isfinite(rezultat.skorosti(:)))
    error('%s', 'В результате пассивной кинематики обнаружены неконечные скорости.');
end

oblast_poleta = proverit_oblast_poleta( ...
    scenarii.oblast_poleta, ...
    'области полета сценария stroi_malyi');
proverit_vse_polozheniya_v_oblasti(rezultat.polozheniya, oblast_poleta);
proverit_vosproizvodimost(scenarii, rezultat);
proverit_neizmennost_energii(sostoyaniya_bvs, scenarii, oblast_poleta);
proverit_otrazhenie_ot_granic(oblast_poleta);
proverit_nepodvizhnost_nerabotosposobnogo_bvs(oblast_poleta);

soobshchenie('Кинематика этапа 3 проверена успешно');
end

function proverit_vse_polozheniya_v_oblasti(polozheniya, oblast_poleta)
[chislo_momentov, chislo_bvs, ~] = size(polozheniya);

for nomer_momenta = 1:chislo_momentov
    for nomer_bvs = 1:chislo_bvs
        tochka = reshape(polozheniya(nomer_momenta, nomer_bvs, :), 1, 3);
        if ~tochka_v_oblasti_poleta(tochka, oblast_poleta)
            error('%s', sprintf( ...
                'Положение БВС номер %d на шаге %d вышло за границы области полета.', ...
                nomer_bvs, nomer_momenta));
        end
    end
end
end

function proverit_vosproizvodimost(scenarii, rezultat_etalonnyi)
povtornyi_rezultat = raschet_passivnoi_kinematiki(scenarii);

if ~isequaln(rezultat_etalonnyi.vremya, povtornyi_rezultat.vremya) ...
        || ~isequaln(rezultat_etalonnyi.id_bvs, povtornyi_rezultat.id_bvs) ...
        || ~isequaln(rezultat_etalonnyi.polozheniya, povtornyi_rezultat.polozheniya) ...
        || ~isequaln(rezultat_etalonnyi.skorosti, povtornyi_rezultat.skorosti)
    error('%s', 'Повторный расчет пассивной кинематики не совпал с первым расчетом.');
end
end

function proverit_neizmennost_energii(sostoyaniya_bvs, scenarii, oblast_poleta)
nachalnye_energii = [sostoyaniya_bvs.zapas_energii];
tekushchie_sostoyaniya = sostoyaniya_bvs;
chislo_shagov = 10;

for nomer_shaga = 1:chislo_shagov
    tekushchie_sostoyaniya = shag_kinematiki_roya( ...
        tekushchie_sostoyaniya, ...
        scenarii.shag_modelirovaniya, ...
        oblast_poleta);
end

itogovye_energii = [tekushchie_sostoyaniya.zapas_energii];
if ~isequaln(nachalnye_energii, itogovye_energii)
    error('%s', 'На этапе 3 запас энергии не должен изменяться.');
end
end

function proverit_otrazhenie_ot_granic(oblast_poleta)
sostoyanie = struct( ...
    'id_bvs', 'kontrol_otrazheniya', ...
    'rol', 'ispytanie', ...
    'polozhenie', [599, 100, 80], ...
    'skorost', [4, 0, 0], ...
    'zapas_energii', 1, ...
    'rabotosposoben', true);

obnovlennoe_sostoyanie = shag_kinematiki_bvs(sostoyanie, 1, oblast_poleta);
ozhidaemoe_polozhenie = [597, 100, 80];
ozhidaemaya_skorost = [-4, 0, 0];

if ~isequaln(obnovlennoe_sostoyanie.polozhenie, ozhidaemoe_polozhenie) ...
        || ~isequaln(obnovlennoe_sostoyanie.skorost, ozhidaemaya_skorost)
    error('%s', 'Отражение от границы области полета работает некорректно.');
end
end

function proverit_nepodvizhnost_nerabotosposobnogo_bvs(oblast_poleta)
sostoyanie = struct( ...
    'id_bvs', 'kontrol_otkaza', ...
    'rol', 'ispytanie', ...
    'polozhenie', [100, 100, 100], ...
    'skorost', [3, 2, 1], ...
    'zapas_energii', 1, ...
    'rabotosposoben', false);

obnovlennoe_sostoyanie = shag_kinematiki_bvs(sostoyanie, 2, oblast_poleta);
if ~isequaln(obnovlennoe_sostoyanie.polozhenie, sostoyanie.polozhenie) ...
        || ~isequaln(obnovlennoe_sostoyanie.skorost, sostoyanie.skorost)
    error('%s', 'Неработоспособный БВС не должен менять положение и скорость.');
end
end
