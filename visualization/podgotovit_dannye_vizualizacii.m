function dannye_vizualizacii = podgotovit_dannye_vizualizacii(demonstraciya)
if nargin < 1 || ~isstruct(demonstraciya)
    error('%s', 'Для подготовки визуализации требуется структура демонстрации.');
end

obyazatelnye_polya = {
    'id_scenariya'
    'scenarii'
    'kinematika'
    'svyaznost'
    'zvenya'
    'peredacha'
    'vremya'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(demonstraciya, imya_polya)
        error('%s', sprintf( ...
            'В структуре демонстрации отсутствует поле %s.', ...
            imya_polya));
    end
end

vremya = demonstraciya.vremya(:).';
chislo_kadrov = numel(vremya);
id_bvs = normalizovat_id_bvs(demonstraciya.kinematika.id_bvs);
chislo_bvs = numel(id_bvs);
zhurnal_sobytii = poluchit_zhurnal_sobytii(demonstraciya.peredacha);

kadry = repmat(struct( ...
    'nomer_kadra', 0, ...
    'vremya', 0, ...
    'polozheniya_bvs', zeros(chislo_bvs, 3), ...
    'skorosti_bvs', zeros(chislo_bvs, 3), ...
    'matrica_smeznosti', false(chislo_bvs), ...
    'zvenya', struct([]), ...
    'golovnye_bvs', {{}}, ...
    'sobytiya_peredachi', struct([])), 1, chislo_kadrov);

for nomer_kadra = 1:chislo_kadrov
    kadr = struct();
    kadr.nomer_kadra = nomer_kadra;
    kadr.vremya = vremya(nomer_kadra);
    kadr.polozheniya_bvs = poluchit_matricu_3d( ...
        demonstraciya.kinematika.polozheniya, ...
        nomer_kadra, ...
        chislo_bvs);
    kadr.skorosti_bvs = poluchit_matricu_3d( ...
        demonstraciya.kinematika.skorosti, ...
        nomer_kadra, ...
        chislo_bvs);
    kadr.matrica_smeznosti = logical( ...
        poluchit_graf_po_vremeni(demonstraciya.svyaznost, nomer_kadra) ...
        .matrica_smeznosti);
    kadr.zvenya = demonstraciya.zvenya.zvenya_po_vremeni{nomer_kadra};
    kadr.golovnye_bvs = demonstraciya.zvenya.golovnye_bvs_po_vremeni{nomer_kadra};
    kadr.sobytiya_peredachi = vybrat_sobytiya_dlya_kadra( ...
        zhurnal_sobytii, ...
        kadr.vremya);
    kadry(nomer_kadra) = kadr;
end

dannye_vizualizacii = struct();
dannye_vizualizacii.id_scenariya = demonstraciya.id_scenariya;
dannye_vizualizacii.vremya = vremya;
dannye_vizualizacii.kadry = kadry;
dannye_vizualizacii.id_bvs = id_bvs;
dannye_vizualizacii.granicy_oblasti = demonstraciya.scenarii.oblast_poleta;
dannye_vizualizacii.prepyatstviya = demonstraciya.scenarii.prepyatstviya;
dannye_vizualizacii.zony_zapreta = demonstraciya.scenarii.zony_zapreta;
dannye_vizualizacii.tseli_zadaniya = demonstraciya.scenarii.tseli_zadaniya;
dannye_vizualizacii.pokazateli = sobrat_pokazateli(demonstraciya, vremya);
dannye_vizualizacii.peredacha = demonstraciya.peredacha;
dannye_vizualizacii.primechanie = [ ...
    'Кадры визуализации подготовлены по рассчитанным данным этапов 2–6 ' ...
    'без изменения результатов моделирования.' ...
    ];
end

function znacheniya = poluchit_matricu_3d(massiv, nomer_kadra, chislo_bvs)
znacheniya = reshape(massiv(nomer_kadra, :, :), chislo_bvs, 3);
if ~all(isfinite(znacheniya(:)))
    error('%s', 'Кадр визуализации содержит нечисловые координаты.');
end
end

function graf = poluchit_graf_po_vremeni(rezultat_svyaznosti, nomer_kadra)
grafy = rezultat_svyaznosti.grafy_po_vremeni;
if iscell(grafy)
    graf = grafy{nomer_kadra};
else
    graf = grafy(nomer_kadra);
end
end

function zhurnal_sobytii = poluchit_zhurnal_sobytii(rezultat_peredachi)
if ~isfield(rezultat_peredachi, 'zhurnal_sobytii') ...
        || isempty(rezultat_peredachi.zhurnal_sobytii)
    zhurnal_sobytii = struct([]);
else
    zhurnal_sobytii = rezultat_peredachi.zhurnal_sobytii;
end
end

function sobytiya = vybrat_sobytiya_dlya_kadra(zhurnal_sobytii, vremya_kadra)
if isempty(zhurnal_sobytii)
    sobytiya = struct([]);
    return
end

maska = false(1, numel(zhurnal_sobytii));
for nomer_sobytiya = 1:numel(zhurnal_sobytii)
    maska(nomer_sobytiya) = abs( ...
        zhurnal_sobytii(nomer_sobytiya).vremya_sobytiya - vremya_kadra) < 1e-9;
end

sobytiya = zhurnal_sobytii(maska);
end

function pokazateli = sobrat_pokazateli(demonstraciya, vremya)
grafy = demonstraciya.svyaznost.grafy_po_vremeni;
if iscell(grafy)
    grafy = [grafy{:}];
end

pokazateli_zvenev = demonstraciya.zvenya.pokazateli_po_vremeni;
zhurnal_sobytii = poluchit_zhurnal_sobytii(demonstraciya.peredacha);

chislo_momentov = numel(vremya);
nakoplennoe_chislo_dostavlennyh = zeros(1, chislo_momentov);
nakoplennoe_chislo_poteryannyh = zeros(1, chislo_momentov);
dolya_dostavlennyh_po_vremeni = zeros(1, chislo_momentov);
srednyaya_zaderzhka_dostavki_po_vremeni = zeros(1, chislo_momentov);
srednee_chislo_peresylok_po_vremeni = zeros(1, chislo_momentov);

for nomer_momenta = 1:chislo_momentov
    [chislo_dostavlennyh, chislo_poteryannyh, dostavlennye_do_momenta] = ...
        poluchit_schetchiki_soobshchenii(zhurnal_sobytii, vremya(nomer_momenta));
    nakoplennoe_chislo_dostavlennyh(nomer_momenta) = chislo_dostavlennyh;
    nakoplennoe_chislo_poteryannyh(nomer_momenta) = chislo_poteryannyh;

    if demonstraciya.peredacha.chislo_soobshchenii > 0
        dolya_dostavlennyh_po_vremeni(nomer_momenta) = ...
            chislo_dostavlennyh / demonstraciya.peredacha.chislo_soobshchenii;
    end

    if isempty(dostavlennye_do_momenta)
        srednyaya_zaderzhka_dostavki_po_vremeni(nomer_momenta) = 0;
        srednee_chislo_peresylok_po_vremeni(nomer_momenta) = 0;
    else
        srednyaya_zaderzhka_dostavki_po_vremeni(nomer_momenta) = mean( ...
            [dostavlennye_do_momenta.zaderzhka_dostavki_s]);
        srednee_chislo_peresylok_po_vremeni(nomer_momenta) = mean( ...
            [dostavlennye_do_momenta.chislo_peresylok]);
    end
end

pokazateli = struct();
pokazateli.chislo_bvs = demonstraciya.kinematika.chislo_bvs;
pokazateli.chislo_linii_po_vremeni = [grafy.chislo_linii];
pokazateli.srednyaya_stepen_po_vremeni = [grafy.srednyaya_stepen];
pokazateli.chislo_zvenev_po_vremeni = [pokazateli_zvenev.chislo_zvenev];
pokazateli.chislo_odinochnyh_zvenev_po_vremeni = ...
    [pokazateli_zvenev.chislo_odinochnyh_zvenev];
pokazateli.srednyaya_poleznost_linii_vnutri_zvenev_po_vremeni = ...
    [pokazateli_zvenev.srednyaya_poleznost_linii_vnutri_zvenev];
pokazateli.dolya_dostavlennyh_po_vremeni = dolya_dostavlennyh_po_vremeni;
pokazateli.nakoplennoe_chislo_dostavlennyh = nakoplennoe_chislo_dostavlennyh;
pokazateli.nakoplennoe_chislo_poteryannyh = nakoplennoe_chislo_poteryannyh;
pokazateli.srednyaya_zaderzhka_dostavki_po_vremeni = ...
    srednyaya_zaderzhka_dostavki_po_vremeni;
pokazateli.srednee_chislo_peresylok_po_vremeni = ...
    srednee_chislo_peresylok_po_vremeni;
pokazateli.dolya_vremeni_svyaznogo_roya = ...
    demonstraciya.svyaznost.dolya_vremeni_svyaznogo_roya;
pokazateli.srednee_chislo_zvenev = demonstraciya.zvenya.srednee_chislo_zvenev;
pokazateli.dolya_dostavlennyh = demonstraciya.peredacha.dolya_dostavlennyh;
pokazateli.primechanie = [ ...
    'Показатели визуализации собраны по рассчитанным слоям связности, ' ...
    'звеньев и передачи сообщений.' ...
    ];
end

function [chislo_dostavlennyh, chislo_poteryannyh, dostavlennye_soobshcheniya] = poluchit_schetchiki_soobshchenii(zhurnal_sobytii, tekushchee_vremya)
chislo_dostavlennyh = 0;
chislo_poteryannyh = 0;
dostavlennye_soobshcheniya = struct([]);

if isempty(zhurnal_sobytii)
    return
end

for nomer_sobytiya = 1:numel(zhurnal_sobytii)
    sobytie = zhurnal_sobytii(nomer_sobytiya);
    if sobytie.vremya_sobytiya - tekushchee_vremya > 1e-9
        continue
    end

    if strcmp(sobytie.tip_sobytiya, 'dostavleno')
        chislo_dostavlennyh = chislo_dostavlennyh + 1;
        if isempty(dostavlennye_soobshcheniya)
            dostavlennye_soobshcheniya = sobytie.soobshchenie;
        else
            dostavlennye_soobshcheniya(end + 1) = sobytie.soobshchenie; %#ok<AGROW>
        end
    elseif startsWith(sobytie.tip_sobytiya, 'poteryano_')
        chislo_poteryannyh = chislo_poteryannyh + 1;
    end
end
end

function id_bvs = normalizovat_id_bvs(id_bvs)
if isstring(id_bvs)
    id_bvs = cellstr(id_bvs(:).');
elseif ischar(id_bvs)
    id_bvs = {id_bvs};
elseif ~iscell(id_bvs)
    error('%s', ...
        'Идентификаторы БВС в данных визуализации должны быть списком строк.');
end

id_bvs = cellfun(@(znachenie) char(string(znachenie)), ...
    id_bvs, 'UniformOutput', false);
end
