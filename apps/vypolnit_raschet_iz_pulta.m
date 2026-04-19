function [sostoyanie_pulta, demonstraciya, dannye_vizualizacii] = vypolnit_raschet_iz_pulta(vhod)
if nargin < 1 || ~isstruct(vhod)
    error('%s', ...
        'Для запуска расчета из пульта требуется структура пульта или его состояния.');
end

[sostoyanie_pulta, pult] = razobrat_vhod_pulta(vhod);
[parametry_svyazi, parametry_zvenev, parametry_peredachi] = ...
    poluchit_parametry(vhod, sostoyanie_pulta, pult);
put_k_scenariyu = opredelit_put_k_scenariyu(vhod, sostoyanie_pulta, pult);
scenarii = zagruzit_scenarii(put_k_scenariyu);

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

demonstraciya = struct();
demonstraciya.id_scenariya = char(string(scenarii.id_scenariya));
demonstraciya.scenarii = scenarii;
demonstraciya.kinematika = rezultat_kinematiki;
demonstraciya.svyaznost = rezultat_svyaznosti;
demonstraciya.zvenya = rezultat_zvenev;
demonstraciya.peredacha = rezultat_peredachi;
demonstraciya.vremya = rezultat_kinematiki.vremya;
demonstraciya.primechanie = [ ...
    'Демонстрационные данные собраны из пульта исследователя по слоям ' ...
    'этапов 2–7 без изменения исходных сценариев.' ...
    ];

dannye_vizualizacii = podgotovit_dannye_vizualizacii(demonstraciya);

sostoyanie_pulta.tekushchii_scenarii = scenarii;
sostoyanie_pulta.tekushchii_put_k_scenariyu = put_k_scenariyu;
sostoyanie_pulta.parametry_svyazi = parametry_svyazi;
sostoyanie_pulta.parametry_zvenev = parametry_zvenev;
sostoyanie_pulta.parametry_peredachi = parametry_peredachi;
sostoyanie_pulta.demonstraciya = demonstraciya;
sostoyanie_pulta.dannye_vizualizacii = dannye_vizualizacii;
sostoyanie_pulta.tekushchii_kadr = 1;
sostoyanie_pulta.rezultat_poslednego_zapuska = ...
    sobrat_rezultat_poslednego_zapuska(demonstraciya);
sostoyanie_pulta.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
    sostoyanie_pulta.zhurnal_soobshchenii, ...
    ['Расчет сценария `' demonstraciya.id_scenariya '` выполнен из пульта.']);
end

function [sostoyanie_pulta, pult] = razobrat_vhod_pulta(vhod)
if isfield(vhod, 'okno') && isfield(vhod, 'elementy')
    pult = vhod;
    if isfield(vhod, 'sostoyanie') && isstruct(vhod.sostoyanie)
        sostoyanie_pulta = vhod.sostoyanie;
    else
        sostoyanie_pulta = getappdata(vhod.okno, 'pult_sostoyanie');
    end
elseif isfield(vhod, 'koren_proekta') && isfield(vhod, 'spisok_scenariev')
    pult = [];
    sostoyanie_pulta = vhod;
else
    error('%s', ...
        'Входная структура не похожа ни на пульт, ни на состояние пульта.');
end

if isempty(sostoyanie_pulta) || ~isstruct(sostoyanie_pulta)
    error('%s', 'Не удалось определить текущее состояние пульта.');
end
end

function [parametry_svyazi, parametry_zvenev, parametry_peredachi] = poluchit_parametry(vhod, sostoyanie_pulta, pult)
if ~isempty(pult)
    [parametry_svyazi, parametry_zvenev, parametry_peredachi] = ...
        poluchit_parametry_iz_pulta(pult);
else
    parametry_svyazi = sostoyanie_pulta.parametry_svyazi;
    parametry_zvenev = sostoyanie_pulta.parametry_zvenev;
    parametry_peredachi = sostoyanie_pulta.parametry_peredachi;
    [parametry_svyazi, parametry_zvenev, parametry_peredachi] = ...
        proverit_parametry_pulta( ...
        parametry_svyazi, ...
        parametry_zvenev, ...
        parametry_peredachi);
end

if nargin < 1 || isempty(vhod) %#ok<INUSD>
    error('%s', 'Не удалось получить параметры из состояния пульта.');
end
end

function put_k_scenariyu = opredelit_put_k_scenariyu(~, sostoyanie_pulta, pult)
if ~isempty(pult)
    vybrannyi_id = char(string(pult.elementy.scenariya.spisok_scenariev.Value));
    put_k_scenariyu = nayti_put_k_scenariyu( ...
        sostoyanie_pulta.spisok_scenariev, ...
        vybrannyi_id);
    return
end

if isfield(sostoyanie_pulta, 'tekushchii_put_k_scenariyu') ...
        && isfile(sostoyanie_pulta.tekushchii_put_k_scenariyu)
    put_k_scenariyu = sostoyanie_pulta.tekushchii_put_k_scenariyu;
    return
end

if isfield(sostoyanie_pulta, 'tekushchii_scenarii') ...
        && isstruct(sostoyanie_pulta.tekushchii_scenarii) ...
        && isfield(sostoyanie_pulta.tekushchii_scenarii, 'id_scenariya')
    put_k_scenariyu = nayti_put_k_scenariyu( ...
        sostoyanie_pulta.spisok_scenariev, ...
        char(string(sostoyanie_pulta.tekushchii_scenarii.id_scenariya)));
    return
end

error('%s', 'Не удалось определить путь к сценарию для расчета из пульта.');
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
    'Сценарий `%s` отсутствует в списке сценариев пульта.', ...
    identifikator));
end

function rezultat = sobrat_rezultat_poslednego_zapuska(demonstraciya)
rezultat = struct();
rezultat.id_scenariya = demonstraciya.id_scenariya;
rezultat.chislo_bvs = demonstraciya.kinematika.chislo_bvs;
rezultat.vremya_modelirovaniya = demonstraciya.kinematika.vremya_modelirovaniya;
rezultat.shag_modelirovaniya = demonstraciya.kinematika.shag_modelirovaniya;
rezultat.dolya_vremeni_svyaznogo_roya = ...
    demonstraciya.svyaznost.dolya_vremeni_svyaznogo_roya;
rezultat.srednee_chislo_zvenev = demonstraciya.zvenya.srednee_chislo_zvenev;
rezultat.dolya_dostavlennyh = demonstraciya.peredacha.dolya_dostavlennyh;
rezultat.srednyaya_zaderzhka_dostavki_s = ...
    demonstraciya.peredacha.srednyaya_zaderzhka_dostavki_s;
rezultat.primechanie = [ ...
    'Последний запуск из пульта содержит готовые результаты кинематики, ' ...
    'связности, звеньев и передачи сообщений.' ...
    ];
end
