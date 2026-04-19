function parametry = podgotovit_parametry_simulink_stenda(koren_proekta, id_scenariya)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для подготовки параметров Simulink-стенда требуется корень проекта.');
end

if nargin < 2 || strlength(string(id_scenariya)) == 0
    id_scenariya = "stroi_malyi";
end

spisok_putei = spisok_scenariev(koren_proekta);
put_k_scenariyu = nayti_put_k_scenariyu(spisok_putei, char(string(id_scenariya)));
scenarii = zagruzit_scenarii(put_k_scenariyu);

parametry = struct();
parametry.id_scenariya = char(string(scenarii.id_scenariya));
parametry.parametry_svyazi = parametry_svyazi_po_umolchaniyu();
parametry.parametry_zvenev = parametry_zvenev_po_umolchaniyu();
parametry.parametry_peredachi = parametry_peredachi_po_umolchaniyu();
parametry.vremya_modelirovaniya = scenarii.vremya_modelirovaniya;
parametry.shag_modelirovaniya = scenarii.shag_modelirovaniya;
parametry.primechanie = [ ...
    'Параметры подготовлены для обзорного Simulink-представления ' ...
    'стенда роя БВС.' ...
    ];
end

function put_k_scenariyu = nayti_put_k_scenariyu(spisok_putei, identifikator)
put_k_scenariyu = '';

for nomer_puti = 1:numel(spisok_putei)
    [~, imya_scenariya] = fileparts(spisok_putei{nomer_puti});
    if strcmp(imya_scenariya, identifikator)
        put_k_scenariyu = spisok_putei{nomer_puti};
        return
    end
end

error('%s', sprintf( ...
    'Сценарий `%s` отсутствует в списке базовых сценариев.', ...
    identifikator));
end
