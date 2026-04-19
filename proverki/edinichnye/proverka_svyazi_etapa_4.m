function rezultat_svyaznosti = proverka_svyazi_etapa_4(koren_proekta)
put_k_scenariyu = fullfile( ...
    koren_proekta, 'opyty', 'scenarii', 'bazovye', 'stroi_malyi.json');

if ~isfile(put_k_scenariyu)
    error('%s', sprintf( ...
        'Не найден сценарий для проверки связности этапа 4: %s', ...
        put_k_scenariyu));
end

scenarii = zagruzit_scenarii(put_k_scenariyu);
rezultat_kinematiki = raschet_passivnoi_kinematiki(scenarii);
parametry_svyazi = parametry_svyazi_po_umolchaniyu();

sostoyaniya_bvs_pervogo_momenta = sostavit_sostoyaniya_po_rezultatu( ...
    rezultat_kinematiki, 1);
graf_pervogo_momenta = postroit_graf_svyaznosti( ...
    sostoyaniya_bvs_pervogo_momenta, ...
    parametry_svyazi, ...
    rezultat_kinematiki.shag_modelirovaniya);
rezultat_svyaznosti = raschet_svyaznosti_po_kinematike( ...
    rezultat_kinematiki, ...
    parametry_svyazi);

proverit_razmer_roya(graf_pervogo_momenta, scenarii);
proverit_matricu_smeznosti(graf_pervogo_momenta.matrica_smeznosti);
proverit_matricu_rasstoyanii(graf_pervogo_momenta.matrica_rasstoyanii_m);
proverit_matricu_propusknoy_sposobnosti( ...
    graf_pervogo_momenta.matrica_propusknoy_sposobnosti_bit_s);
proverit_matricu_poleznosti(graf_pervogo_momenta.matrica_poleznosti_linii);
proverit_povtornyi_raschet( ...
    rezultat_kinematiki, ...
    parametry_svyazi, ...
    graf_pervogo_momenta, ...
    rezultat_svyaznosti);
proverit_iskusstvenno_maluyu_dalnost( ...
    sostoyaniya_bvs_pervogo_momenta, ...
    parametry_svyazi, ...
    rezultat_kinematiki.shag_modelirovaniya, ...
    graf_pervogo_momenta.chislo_linii);

soobshchenie('Связность этапа 4 проверена успешно');
end

function proverit_razmer_roya(graf_pervogo_momenta, scenarii)
chislo_bvs_v_grafe = numel(graf_pervogo_momenta.id_bvs);
chislo_bvs_v_scenarii = numel(scenarii.sostav_roya);

if chislo_bvs_v_grafe ~= chislo_bvs_v_scenarii
    error('%s', sprintf( ...
        'Число БВС в графе связности (%d) не совпадает с числом БВС в сценарии (%d).', ...
        chislo_bvs_v_grafe, chislo_bvs_v_scenarii));
end
end

function proverit_matricu_smeznosti(matrica_smeznosti)
if ~isequaln(matrica_smeznosti, matrica_smeznosti.')
    error('%s', 'Матрица смежности этапа 4 должна быть симметричной.');
end

if any(diag(matrica_smeznosti))
    error('%s', 'На диагонали матрицы смежности этапа 4 не должно быть связей.');
end
end

function proverit_matricu_rasstoyanii(matrica_rasstoyanii_m)
if ~all(isfinite(matrica_rasstoyanii_m(:)))
    error('%s', 'Матрица расстояний этапа 4 должна содержать только конечные значения.');
end

if any(matrica_rasstoyanii_m(:) < 0)
    error('%s', 'Матрица расстояний этапа 4 не должна содержать отрицательные значения.');
end
end

function proverit_matricu_propusknoy_sposobnosti(matrica_propusknoy_sposobnosti_bit_s)
if ~all(isfinite(matrica_propusknoy_sposobnosti_bit_s(:)))
    error('%s', 'Матрица пропускной способности этапа 4 должна содержать только конечные значения.');
end

if any(matrica_propusknoy_sposobnosti_bit_s(:) < 0)
    error('%s', 'Матрица пропускной способности этапа 4 не должна содержать отрицательные значения.');
end
end

function proverit_matricu_poleznosti(matrica_poleznosti_linii)
if ~all(isfinite(matrica_poleznosti_linii(:)))
    error('%s', 'Матрица полезности линии связи должна содержать только конечные значения.');
end

if any(matrica_poleznosti_linii(:) < 0) || any(matrica_poleznosti_linii(:) > 1)
    error('%s', 'Полезность линии связи должна находиться в диапазоне от 0 до 1.');
end
end

function proverit_povtornyi_raschet(rezultat_kinematiki, parametry_svyazi, graf_pervogo_momenta, rezultat_svyaznosti)

povtornyi_graf = postroit_graf_svyaznosti( ...
    sostavit_sostoyaniya_po_rezultatu(rezultat_kinematiki, 1), ...
    parametry_svyazi, ...
    rezultat_kinematiki.shag_modelirovaniya);
povtornyi_rezultat = raschet_svyaznosti_po_kinematike( ...
    rezultat_kinematiki, ...
    parametry_svyazi);

if ~isequaln(graf_pervogo_momenta, povtornyi_graf)
    error('%s', 'Повторное построение графа связности дало другой результат.');
end

if ~isequaln(rezultat_svyaznosti, povtornyi_rezultat)
    error('%s', 'Повторный расчет связности по кинематике дало другой результат.');
end
end

function proverit_iskusstvenno_maluyu_dalnost(sostoyaniya_bvs, parametry_svyazi, shag_rascheta, chislo_linii_etalon)

parametry_s_maloi_dalnostyu = parametry_svyazi;
parametry_s_maloi_dalnostyu.maksimalnaya_dalnost_m = 5.0;
parametry_s_maloi_dalnostyu = proverit_parametry_svyazi( ...
    parametry_s_maloi_dalnostyu);

graf_s_maloi_dalnostyu = postroit_graf_svyaznosti( ...
    sostoyaniya_bvs, ...
    parametry_s_maloi_dalnostyu, ...
    shag_rascheta);

if graf_s_maloi_dalnostyu.chislo_linii > chislo_linii_etalon
    error('%s', [ ...
        'При искусственно малой максимальной дальности число линий ' ...
        'не должно возрастать.' ...
        ]);
end
end

function sostoyaniya_bvs = sostavit_sostoyaniya_po_rezultatu(rezultat_kinematiki, nomer_momenta)

chislo_bvs = rezultat_kinematiki.chislo_bvs;
sostoyaniya_bvs = repmat(struct( ...
    'id_bvs', '', ...
    'rol', '', ...
    'polozhenie', zeros(1, 3), ...
    'skorost', zeros(1, 3), ...
    'zapas_energii', 0, ...
    'rabotosposoben', true), 1, chislo_bvs);

for nomer_bvs = 1:chislo_bvs
    sostoyanie = struct();
    sostoyanie.id_bvs = rezultat_kinematiki.id_bvs{nomer_bvs};
    sostoyanie.rol = 'iz_rezultata_kinematiki';
    sostoyanie.polozhenie = reshape( ...
        rezultat_kinematiki.polozheniya(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyanie.skorost = reshape( ...
        rezultat_kinematiki.skorosti(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyanie.zapas_energii = 0;
    sostoyanie.rabotosposoben = true;
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyanie);
end
end
