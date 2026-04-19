function rezultat_opyta = vypolnit_odin_opyt(koren_proekta, variant_opyta)
if nargin < 2
    error('%s', ...
        'Для выполнения одного опыта требуются корень проекта и вариант опыта.');
end

if ~isstruct(variant_opyta)
    error('%s', 'Вариант опыта должен быть передан в виде структуры.');
end

put_k_scenariyu = opredelit_put_k_scenariyu(koren_proekta, variant_opyta.id_scenariya);
scenarii = zagruzit_scenarii(put_k_scenariyu);

parametry_svyazi = proverit_parametry_svyazi(variant_opyta.parametry_svyazi);
parametry_zvenev = proverit_parametry_zvenev(variant_opyta.parametry_zvenev);
parametry_peredachi = proverit_parametry_peredachi( ...
    variant_opyta.parametry_peredachi);

timer_opyta = tic;
rezultat_kinematiki = raschet_passivnoi_kinematiki(scenarii);
rezultat_svyaznosti = raschet_svyaznosti_po_kinematike( ...
    rezultat_kinematiki, ...
    parametry_svyazi);
rezultat_zvenev = raschet_zvenev_po_svyaznosti( ...
    rezultat_svyaznosti, ...
    parametry_zvenev);
rezultat_peredachi = raschet_peredachi_po_trasse( ...
    scenarii, ...
    rezultat_kinematiki, ...
    rezultat_svyaznosti, ...
    rezultat_zvenev, ...
    parametry_peredachi);
vremya_vypolneniya_s = toc(timer_opyta);

rezultat_opyta = struct();
rezultat_opyta.id_serii = char(string(variant_opyta.id_serii));
rezultat_opyta.id_varianta = char(string(variant_opyta.id_varianta));
rezultat_opyta.id_scenariya = char(string(variant_opyta.id_scenariya));
rezultat_opyta.nomer_povtora = double(variant_opyta.nomer_povtora);
rezultat_opyta.kinematika = rezultat_kinematiki;
rezultat_opyta.svyaznost = rezultat_svyaznosti;
rezultat_opyta.zvenya = rezultat_zvenev;
rezultat_opyta.peredacha = rezultat_peredachi;
rezultat_opyta.vremya_vypolneniya_s = double(vremya_vypolneniya_s);
rezultat_opyta.primechanie = [ ...
    'Один расчетный опыт выполнен по существующим слоям кинематики, ' ...
    'связности, звеньев и передачи без изменения траекторий БВС.' ...
    ];
rezultat_opyta.pokazateli = izvlech_pokazateli_opyta(rezultat_opyta);
end

function put_k_scenariyu = opredelit_put_k_scenariyu(koren_proekta, id_scenariya)
spisok_putei = spisok_scenariev(koren_proekta);
put_k_scenariyu = '';

for nomer_puti = 1:numel(spisok_putei)
    [~, imya_scenariya] = fileparts(spisok_putei{nomer_puti});
    if strcmp(imya_scenariya, char(string(id_scenariya)))
        put_k_scenariyu = spisok_putei{nomer_puti};
        break
    end
end

if strlength(string(put_k_scenariyu)) == 0
    error('%s', sprintf( ...
        'Сценарий %s отсутствует в списке базовых сценариев.', ...
        char(string(id_scenariya))));
end
end
