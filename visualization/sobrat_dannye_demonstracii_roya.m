function demonstraciya = sobrat_dannye_demonstracii_roya(koren_proekta, identifikator_ili_put)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Для сбора данных демонстрации требуется корень проекта.');
end

put_k_scenariyu = opredelit_put_k_scenariyu(koren_proekta, identifikator_ili_put);
scenarii = zagruzit_scenarii(put_k_scenariyu);

rezultat_kinematiki = raschet_passivnoi_kinematiki(scenarii);
parametry_svyazi = parametry_svyazi_po_umolchaniyu();
rezultat_svyaznosti = raschet_svyaznosti_po_kinematike( ...
    rezultat_kinematiki, ...
    parametry_svyazi);
parametry_zvenev = parametry_zvenev_po_umolchaniyu();
rezultat_zvenev = raschet_zvenev_po_svyaznosti( ...
    rezultat_svyaznosti, ...
    parametry_zvenev);
parametry_peredachi = parametry_peredachi_po_umolchaniyu();
rezultat_peredachi = raschet_peredachi_po_trasse( ...
    scenarii, ...
    rezultat_kinematiki, ...
    rezultat_svyaznosti, ...
    rezultat_zvenev, ...
    parametry_peredachi);

demonstraciya = struct();
demonstraciya.id_scenariya = char(string(scenarii.id_scenariya));
demonstraciya.scenarii = scenarii;
demonstraciya.kinematika = rezultat_kinematiki;
demonstraciya.svyaznost = rezultat_svyaznosti;
demonstraciya.zvenya = rezultat_zvenev;
demonstraciya.peredacha = rezultat_peredachi;
demonstraciya.vremya = rezultat_kinematiki.vremya;
demonstraciya.primechanie = [ ...
    'Демонстрационный опыт собран по готовым расчетным слоям этапов 2–6 ' ...
    'без изменения траекторий, без управления и без моделей Simulink.' ...
    ];
end

function put_k_scenariyu = opredelit_put_k_scenariyu(koren_proekta, identifikator_ili_put)
if nargin < 2 || strlength(string(identifikator_ili_put)) == 0
    identifikator_ili_put = 'stroi_malyi';
end

znachenie = char(string(identifikator_ili_put));

if isfile(znachenie)
    put_k_scenariyu = znachenie;
    return
end

if contains(znachenie, filesep) || contains(znachenie, '/')
    put_k_scenariyu = fullfile(koren_proekta, znachenie);
else
    put_k_scenariyu = fullfile( ...
        koren_proekta, ...
        'opyty', 'scenarii', 'bazovye', ...
        [znachenie '.json']);
end

if ~isfile(put_k_scenariyu)
    error('%s', sprintf( ...
        'Не найден сценарий для демонстрации: %s', ...
        put_k_scenariyu));
end
end
