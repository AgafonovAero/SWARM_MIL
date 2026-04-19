function pokazateli = otsenit_peredachu(rezultat_peredachi)
if nargin < 1 || ~isstruct(rezultat_peredachi)
    error('%s', ...
        'Для оценки передачи требуется структура результата передачи.');
end

if ~isfield(rezultat_peredachi, 'soobshcheniya') ...
        || ~isfield(rezultat_peredachi, 'zhurnal_sobytii')
    error('%s', [ ...
        'Результат передачи должен содержать поля soobshcheniya и zhurnal_sobytii.' ...
        ]);
end

soobshcheniya = rezultat_peredachi.soobshcheniya;
zhurnal_sobytii = rezultat_peredachi.zhurnal_sobytii;

if ~isstruct(soobshcheniya)
    error('%s', ...
        'Поле soobshcheniya должно быть массивом структур.');
end

chislo_soobshchenii = numel(soobshcheniya);
chislo_dostavlennyh = sum([soobshcheniya.dostavleno]);
chislo_poteryannyh = sum([soobshcheniya.poteryano]);
dolya_dostavlennyh = chislo_dostavlennyh / max(1, chislo_soobshchenii);

zaderzhki = [soobshcheniya([soobshcheniya.dostavleno]).zaderzhka_dostavki_s];
if isempty(zaderzhki)
    srednyaya_zaderzhka = 0;
else
    srednyaya_zaderzhka = mean(zaderzhki);
end

chisla_peresylok = [soobshcheniya.chislo_peresylok];
if isempty(chisla_peresylok)
    srednee_chislo_peresylok = 0;
    maksimalnoe_chislo_peresylok = 0;
else
    srednee_chislo_peresylok = mean(chisla_peresylok);
    maksimalnoe_chislo_peresylok = max(chisla_peresylok);
end

chislo_sobytii_ozhidaniya = 0;
chislo_sobytii_perepolneniya = 0;
if ~isempty(zhurnal_sobytii)
    tipy = {zhurnal_sobytii.tip_sobytiya};
    chislo_sobytii_ozhidaniya = sum(strcmp(tipy, 'ozhidaet'));
    chislo_sobytii_perepolneniya = sum(strcmp( ...
        tipy, ...
        'poteryano_iz_za_perepolneniya_ocheredi'));
end

pokazateli = struct();
pokazateli.chislo_soobshchenii = chislo_soobshchenii;
pokazateli.chislo_dostavlennyh = chislo_dostavlennyh;
pokazateli.chislo_poteryannyh = chislo_poteryannyh;
pokazateli.dolya_dostavlennyh = dolya_dostavlennyh;
pokazateli.srednyaya_zaderzhka_dostavki_s = srednyaya_zaderzhka;
pokazateli.srednee_chislo_peresylok = srednee_chislo_peresylok;
pokazateli.maksimalnoe_chislo_peresylok = maksimalnoe_chislo_peresylok;
pokazateli.chislo_sobytii_ozhidaniya = chislo_sobytii_ozhidaniya;
pokazateli.chislo_sobytii_perepolneniya_ocheredi = ...
    chislo_sobytii_perepolneniya;

proverit_konechnost_pokazateley(pokazateli);
end

function proverit_konechnost_pokazateley(pokazateli)
chisla = [ ...
    pokazateli.chislo_soobshchenii
    pokazateli.chislo_dostavlennyh
    pokazateli.chislo_poteryannyh
    pokazateli.dolya_dostavlennyh
    pokazateli.srednyaya_zaderzhka_dostavki_s
    pokazateli.srednee_chislo_peresylok
    pokazateli.maksimalnoe_chislo_peresylok
    pokazateli.chislo_sobytii_ozhidaniya
    pokazateli.chislo_sobytii_perepolneniya_ocheredi
    ];

if ~all(isfinite(chisla))
    error('%s', ...
        'Показатели передачи должны быть конечными.');
end
end
