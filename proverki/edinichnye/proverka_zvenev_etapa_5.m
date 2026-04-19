function rezultat_zvenev_vo_vremeni = proverka_zvenev_etapa_5(koren_proekta)
put_k_scenariyu = fullfile( ...
    koren_proekta, 'opyty', 'scenarii', 'bazovye', 'stroi_malyi.json');

if ~isfile(put_k_scenariyu)
    error('%s', sprintf( ...
        'Не найден сценарий для проверки звеньев этапа 5: %s', ...
        put_k_scenariyu));
end

scenarii = zagruzit_scenarii(put_k_scenariyu);
nachalnye_sostoyaniya = sozdat_sostoyanie_bvs_iz_scenariya(scenarii);
rezultat_kinematiki = raschet_passivnoi_kinematiki(scenarii);
parametry_svyazi = parametry_svyazi_po_umolchaniyu();
rezultat_svyaznosti = raschet_svyaznosti_po_kinematike( ...
    rezultat_kinematiki, ...
    parametry_svyazi);
parametry_zvenev = parametry_zvenev_po_umolchaniyu();

graf_pervogo_momenta = poluchit_pervyi_graf(rezultat_svyaznosti);
sostoyaniya_pervogo_momenta = sostavit_sostoyaniya_dlya_momenta( ...
    rezultat_kinematiki, ...
    nachalnye_sostoyaniya, ...
    1);
rezultat_zvenev = sformirovat_zvenya_po_grafu( ...
    graf_pervogo_momenta, ...
    sostoyaniya_pervogo_momenta, ...
    parametry_zvenev);
rezultat_golovnyh = naznachit_golovnye_bvs( ...
    rezultat_zvenev, ...
    graf_pervogo_momenta, ...
    sostoyaniya_pervogo_momenta, ...
    parametry_zvenev);
pokazateli_pervogo_momenta = otsenit_zvenya( ...
    rezultat_zvenev, ...
    rezultat_golovnyh, ...
    graf_pervogo_momenta);
rezultat_zvenev_vo_vremeni = raschet_zvenev_po_svyaznosti( ...
    rezultat_svyaznosti, ...
    parametry_zvenev);

proverit_chislo_bvs(scenarii, rezultat_zvenev);
proverit_raspredelenie_po_zvenyam(rezultat_zvenev);
proverit_ogranichenie_razmera(rezultat_zvenev, parametry_zvenev);
proverit_golovnye_bvs(rezultat_golovnyh);
proverit_konechnost_pokazateley(pokazateli_pervogo_momenta);
proverit_povtornyi_raschet( ...
    rezultat_svyaznosti, ...
    parametry_zvenev, ...
    rezultat_zvenev_vo_vremeni);
proverit_rezhim_odin_uchastnik_na_zveno( ...
    graf_pervogo_momenta, ...
    sostoyaniya_pervogo_momenta, ...
    parametry_zvenev, ...
    rezultat_zvenev.chislo_zvenev);

soobshchenie('Звенья этапа 5 проверены успешно');
end

function graf_pervogo_momenta = poluchit_pervyi_graf(rezultat_svyaznosti)
if iscell(rezultat_svyaznosti.grafy_po_vremeni)
    graf_pervogo_momenta = rezultat_svyaznosti.grafy_po_vremeni{1};
else
    graf_pervogo_momenta = rezultat_svyaznosti.grafy_po_vremeni(1);
end
end

function sostoyaniya_bvs = sostavit_sostoyaniya_dlya_momenta(rezultat_kinematiki, nachalnye_sostoyaniya, nomer_momenta)

chislo_bvs = rezultat_kinematiki.chislo_bvs;
sostoyaniya_bvs = nachalnye_sostoyaniya;

for nomer_bvs = 1:chislo_bvs
    sostoyaniya_bvs(nomer_bvs).polozhenie = reshape( ...
        rezultat_kinematiki.polozheniya(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyaniya_bvs(nomer_bvs).skorost = reshape( ...
        rezultat_kinematiki.skorosti(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyaniya_bvs(nomer_bvs));
end
end

function proverit_chislo_bvs(scenarii, rezultat_zvenev)
chislo_bvs_v_scenarii = numel(scenarii.sostav_roya);
if chislo_bvs_v_scenarii ~= 5 || rezultat_zvenev.chislo_zvenev < 1
    error('%s', [ ...
        'Сценарий stroi_malyi должен содержать 5 БВС и приводить к ' ...
        'формированию хотя бы одного звена.' ...
        ]);
end
end

function proverit_raspredelenie_po_zvenyam(rezultat_zvenev)
nomera_zvenev = rezultat_zvenev.nomer_zvena_dlya_bvs;
if any(nomera_zvenev < 1)
    error('%s', 'Каждый БВС должен входить ровно в одно звено.');
end

if numel(nomera_zvenev) ~= numel(rezultat_zvenev.id_bvs)
    error('%s', [ ...
        'Размер вектора соответствия БВС и звеньев должен совпадать с ' ...
        'числом БВС.' ...
        ]);
end
end

function proverit_ogranichenie_razmera(rezultat_zvenev, parametry_zvenev)
for nomer_zvena = 1:numel(rezultat_zvenev.zvenya)
    razmer_zvena = rezultat_zvenev.zvenya(nomer_zvena).razmer_zvena;
    if razmer_zvena > parametry_zvenev.maksimalnyi_razmer_zvena
        error('%s', sprintf( ...
            'Размер звена %d превышает допустимое ограничение.', ...
            nomer_zvena));
    end
end
end

function proverit_golovnye_bvs(rezultat_golovnyh)
for nomer_zvena = 1:numel(rezultat_golovnyh.zvenya)
    zveno = rezultat_golovnyh.zvenya(nomer_zvena);
    if ~isfield(zveno, 'golovnoi_bvs') || isempty(zveno.golovnoi_bvs)
        error('%s', sprintf( ...
            'Для звена %d не назначен головной БВС.', ...
            nomer_zvena));
    end

    if ~any(strcmp(zveno.id_bvs, zveno.golovnoi_bvs))
        error('%s', sprintf( ...
            'Головной БВС звена %d не входит в состав этого звена.', ...
            nomer_zvena));
    end
end
end

function proverit_konechnost_pokazateley(pokazateli)
znacheniya = [ ...
    pokazateli.chislo_zvenev
    pokazateli.chislo_odinochnyh_zvenev
    pokazateli.srednii_razmer_zvena
    pokazateli.maksimalnyi_razmer_zvena
    pokazateli.srednyaya_poleznost_linii_vnutri_zvenev
    pokazateli.dolya_bvs_naznachennyh_v_zvenya
    pokazateli.dolya_zvenev_s_golovnym_bvs
    ];

if ~all(isfinite(znacheniya))
    error('%s', 'Показатели качества звеньев должны быть конечными.');
end
end

function proverit_povtornyi_raschet(rezultat_svyaznosti, parametry_zvenev, etalonnyi_rezultat)

povtornyi_rezultat = raschet_zvenev_po_svyaznosti( ...
    rezultat_svyaznosti, ...
    parametry_zvenev);

if ~isequaln(etalonnyi_rezultat, povtornyi_rezultat)
    error('%s', 'Повторный расчет звеньев дал другой результат.');
end
end

function proverit_rezhim_odin_uchastnik_na_zveno(graf_pervogo_momenta, sostoyaniya_pervogo_momenta, parametry_zvenev, chislo_zvenev_etalon)

parametry_odinochnyh_zvenev = parametry_zvenev;
parametry_odinochnyh_zvenev.maksimalnyi_razmer_zvena = 1;
parametry_odinochnyh_zvenev = proverit_parametry_zvenev( ...
    parametry_odinochnyh_zvenev);

rezultat_odinochnyh_zvenev = sformirovat_zvenya_po_grafu( ...
    graf_pervogo_momenta, ...
    sostoyaniya_pervogo_momenta, ...
    parametry_odinochnyh_zvenev);

if rezultat_odinochnyh_zvenev.chislo_zvenev < chislo_zvenev_etalon
    error('%s', [ ...
        'При ограничении размера звена до одного участника число звеньев ' ...
        'не должно уменьшаться.' ...
        ]);
end

for nomer_zvena = 1:numel(rezultat_odinochnyh_zvenev.zvenya)
    if rezultat_odinochnyh_zvenev.zvenya(nomer_zvena).razmer_zvena ~= 1
        error('%s', [ ...
            'При максимальном размере звена, равном 1, каждое звено ' ...
            'должно содержать ровно один БВС.' ...
            ]);
    end
end
end
