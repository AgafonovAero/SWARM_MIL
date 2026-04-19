function pokazateli = izvlech_pokazateli_opyta(rezultat_opyta)
if nargin < 1 || ~isstruct(rezultat_opyta)
    error('%s', ...
        'Для извлечения показателей требуется структура результата опыта.');
end

obyazatelnye_polya = {
    'id_serii'
    'id_varianta'
    'id_scenariya'
    'nomer_povtora'
    'kinematika'
    'svyaznost'
    'zvenya'
    'peredacha'
    'vremya_vypolneniya_s'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_opyta, imya_polya)
        error('%s', sprintf( ...
            'В результате опыта отсутствует поле %s.', ...
            imya_polya));
    end
end

pokazateli = struct();
pokazateli.id_serii = char(string(rezultat_opyta.id_serii));
pokazateli.id_varianta = char(string(rezultat_opyta.id_varianta));
pokazateli.id_scenariya = char(string(rezultat_opyta.id_scenariya));
pokazateli.nomer_povtora = double(rezultat_opyta.nomer_povtora);
pokazateli.chislo_bvs = double(rezultat_opyta.kinematika.chislo_bvs);
pokazateli.dolya_vremeni_svyaznogo_roya = ...
    double(rezultat_opyta.svyaznost.dolya_vremeni_svyaznogo_roya);
pokazateli.srednee_chislo_linii = ...
    double(rezultat_opyta.svyaznost.srednee_chislo_linii);
pokazateli.srednyaya_stepen_bvs = ...
    double(rezultat_opyta.svyaznost.srednyaya_stepen_po_vremeni);
pokazateli.srednee_chislo_zvenev = ...
    double(rezultat_opyta.zvenya.srednee_chislo_zvenev);
pokazateli.srednyaya_dolya_odinochnyh_zvenev = ...
    double(rezultat_opyta.zvenya.srednyaya_dolya_odinochnyh_zvenev);
pokazateli.dolya_dostavlennyh_soobshchenii = ...
    double(rezultat_opyta.peredacha.dolya_dostavlennyh);
pokazateli.chislo_dostavlennyh_soobshchenii = ...
    double(rezultat_opyta.peredacha.chislo_dostavlennyh);
pokazateli.chislo_poteryannyh_soobshchenii = ...
    double(rezultat_opyta.peredacha.chislo_poteryannyh);
pokazateli.srednyaya_zaderzhka_dostavki_s = ...
    double(rezultat_opyta.peredacha.srednyaya_zaderzhka_dostavki_s);
pokazateli.srednee_chislo_peresylok = ...
    double(rezultat_opyta.peredacha.srednee_chislo_peresylok);
pokazateli.maksimalnoe_chislo_peresylok = ...
    double(rezultat_opyta.peredacha.maksimalnoe_chislo_peresylok);
pokazateli.vremya_vypolneniya_s = double(rezultat_opyta.vremya_vypolneniya_s);

proverit_konechnost_pokazateley(pokazateli);
proverit_doli(pokazateli);
end

function proverit_konechnost_pokazateley(pokazateli)
chisla = [ ...
    pokazateli.chislo_bvs
    pokazateli.dolya_vremeni_svyaznogo_roya
    pokazateli.srednee_chislo_linii
    pokazateli.srednyaya_stepen_bvs
    pokazateli.srednee_chislo_zvenev
    pokazateli.srednyaya_dolya_odinochnyh_zvenev
    pokazateli.dolya_dostavlennyh_soobshchenii
    pokazateli.chislo_dostavlennyh_soobshchenii
    pokazateli.chislo_poteryannyh_soobshchenii
    pokazateli.srednyaya_zaderzhka_dostavki_s
    pokazateli.srednee_chislo_peresylok
    pokazateli.maksimalnoe_chislo_peresylok
    pokazateli.vremya_vypolneniya_s
    ];

if ~all(isfinite(chisla))
    error('%s', 'Показатели опыта должны быть конечными числами.');
end
end

function proverit_doli(pokazateli)
spisok_doley = [ ...
    pokazateli.dolya_vremeni_svyaznogo_roya
    pokazateli.srednyaya_dolya_odinochnyh_zvenev
    pokazateli.dolya_dostavlennyh_soobshchenii
    ];

if any(spisok_doley < 0) || any(spisok_doley > 1)
    error('%s', 'Долевые показатели опыта должны находиться в диапазоне от 0 до 1.');
end
end
